# Google Cloud Backup and DR API Export Utility

This repository contains a Bash script to automate the export of configuration and status data from the Google Cloud Backup and DR service.

This tool is designed for cloud administrators and DevOps engineers who need to perform discovery or auditing. It programmatically connects to the Backup and DR management console's REST API, handles the authentication flow, and downloads key information into structured JSON files for analysis, reporting, or as a point-in-time snapshot.

## The Problem This Solves

While the Google Cloud Console provides a user-friendly interface for managing Backup and DR, it can be inefficient for gathering comprehensive data about the entire system's state. Manually clicking through pages to collect information about all clusters, backup jobs, and policies is time-consuming and prone to error.

This script solves that problem by directly querying the service's API, providing a fast, repeatable, and accurate way to dump the raw configuration data.

## How It Works: The Authentication Flow

The Backup and DR API uses a two-step authentication process, which this script automates:

1.  **GCP Authentication:** The script first uses the local user's `gcloud` credentials to generate a standard Google Cloud bearer token.
2.  **Session Authentication:** It then presents this bearer token to the Backup and DR `/session` endpoint to obtain a temporary `session_id`.
3.  **Authenticated API Calls:** This `session_id` is then used as a header in subsequent API calls to prove the user is authenticated and authorized to access the data.

The script queries the `/cluster` and `/backup` endpoints and pretty-prints the resulting JSON into local files.

## Key Features & Skills Demonstrated

-   **REST API Interaction:** Demonstrates proficiency in using `curl` to interact with a secure, multi-step REST API.
-   **Complex Authentication Handling:** Successfully implements a two-factor authentication flow (Bearer Token -> Session ID).
-   **JSON Data Processing:** Uses `jq` to parse and format JSON responses from the API.
-   **Robust Scripting:** Includes dependency checks, strict error handling (`set -e`, `set -u`), and clear, color-coded logging for a professional user experience.
-   **Cloud Automation:** Automates a manual discovery task, showcasing an understanding of infrastructure-as-code and operational efficiency principles.

## How to Use

1.  **Prerequisites:**
    -   Google Cloud SDK (`gcloud`, `gsutil`) installed and authenticated.
    -   `curl` and `jq` command-line utilities must be installed.
    -   Permissions to access the Backup and DR service in the target project.

2.  **Configuration:**
    -   Open the `gcp_backup_dr_export.sh` script.
    -   Update the `PROJECT_ID` and `API_BASE_URL` variables with the details from your Backup and DR management console.

3.  **Execution:**
    -   Make the script executable:
        ```bash
        chmod +x gcp_backup_dr_export.sh
        ```
    -   Run the script:
        ```bash
        ./gcp_backup_dr_export.sh
        ```

## Output

The script will create two files in the current directory containing the complete JSON response from the API endpoints:
-   `cluster_data.json`
-   `backup_data.json`
