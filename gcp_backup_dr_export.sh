#!/bin/bash
#
# This script automates the process of exporting key configuration and status
# data from the Google Cloud Backup and DR service via its REST API. It handles
# the two-step authentication process and saves the output to JSON files for
# discovery, auditing, or analysis.

# --- Configuration ---
#
# ACTION REQUIRED: Update these variables with your management console's details.
# You can find these details in the Google Cloud Console under "Backup and DR".
#
PROJECT_ID="[YOUR-GCP-PROJECT-ID]"

# The base URL of your management console API.
# It looks like: https://bmc-....googleusercontent.com/actifio
API_BASE_URL="[YOUR-MANAGEMENT-CONSOLE-API-URL]"

# --- End of Configuration ---


# --- Script Setup ---
# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error.
set -u
# Fail a pipeline if any command fails, not just the last one.
set -o pipefail

# Define color codes for logging
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Dependency Check ---
# Ensure required command-line tools are installed before starting.
for cmd in gcloud curl jq; do
  if ! command -v "$cmd" &> /dev/null; then
    echo -e "${RED}Error: Required command '$cmd' is not installed. Please install it and try again.${NC}"
    exit 1
  fi
done

# --- Main Execution Logic ---
main() {
  echo "--- Starting Google Cloud Backup and DR Data Export ---"

  # Step 1: Get a bearer token from the local gcloud authenticated user.
  echo -e "${YELLOW}[Step 1/4] Authenticating with gcloud to get an access token...${NC}"
  local token
  token=$(gcloud auth application-default print-access-token)
  echo -e "${GREEN}Authentication successful.${NC}"

  # Step 2: Use the bearer token to log in to the Backup and DR API and get a session ID.
  echo -e "${YELLOW}[Step 2/4] Logging in to the Backup and DR API to get a session ID...${NC}"
  
  local login_response
  login_response=$(curl -s -X POST "${API_BASE_URL}/session" \
    -H "Authorization: Bearer ${token}")
  
  local session_id
  session_id=$(echo "$login_response" | jq -r '.session_id')

  if [[ -z "$session_id" || "$session_id" == "null" ]]; then
    echo -e "${RED}Error: Failed to retrieve a session ID. Check your permissions and API URL.${NC}"
    echo "Full login response from server: ${login_response}"
    exit 1
  fi
  echo -e "${GREEN}Login successful. Session ID obtained.${NC}"

  # Step 3: Fetch and save the /cluster data.
  echo -e "${YELLOW}[Step 3/4] Querying API endpoint for cluster data...${NC}"
  curl -s -X GET "${API_BASE_URL}/cluster" \
    -H "Authorization: Bearer ${token}" \
    -H "backupdr-management-session: Actifio ${session_id}" \
    -H "Content-Type: application/json" | jq . > cluster_data.json
  echo -e "${GREEN}--> Saved cluster data to cluster_data.json${NC}"

  # Step 4: Fetch and save the /backup data.
  echo -e "${YELLOW}[Step 4/4] Querying API endpoint for backup data...${NC}"
  curl -s -X GET "${API_BASE_URL}/backup" \
    -H "Authorization: Bearer ${token}" \
    -H "backupdr-management-session: Actifio ${session_id}" \
    -H "Content-Type: application/json" | jq . > backup_data.json
  echo -e "${GREEN}--> Saved backup data to backup_data.json${NC}"

  echo -e "\n${GREEN}---"
  echo -e "✅ Data export complete."
  echo "All data has been saved to local JSON files in the current directory."
  echo "---${NC}"
}

# Run the main function
main
