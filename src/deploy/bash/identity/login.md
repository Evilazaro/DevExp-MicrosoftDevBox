## Login.sh Script Explanation

This section provides a detailed explanation of the Bash script step by step:

- The script begins with a shebang `#!/bin/bash`, indicating that it's a Bash script.

- `set -e` is used to set the Bash option that ensures the script stops immediately if any command exits with a non-zero status, effectively halting the script on the first error.

- The `usage()` function is defined to provide usage instructions when called. It expects one argument, which is `<subscriptionId>`.

- The `logIntoAzure()` function is defined to attempt a login to Azure. It displays a message, "Attempting to log into Azure...", initiates the Azure login using the `az login` command, and prints "Successfully logged into Azure." upon successful login.

- The `setAzureSubscription()` function is defined to set the Azure subscription to the provided subscription ID. It takes the subscription ID as an argument and attempts to set it using the `az account set --subscription` command. If successful, it prints "Successfully set Azure subscription to `${subscriptionId}`." Otherwise, it displays a failure message and exits the script with an error code.

- The script checks if exactly one command-line argument is provided using `[ "$#" -ne 1 ]`. If there is not exactly one argument, it calls the `usage()` function to display usage instructions and exits the script.

- The provided subscription ID from the command line is stored in the `subscriptionId` variable.

- The `logIntoAzure` function is called to initiate the Azure login process.

- The `setAzureSubscription` function is called with the `subscriptionId` as an argument to configure the Azure subscription.

- If any step in the script fails, it exits with an error message.

This script is designed to facilitate logging into Azure and configuring the Azure subscription based on the provided subscription ID.

### Sample Usage

To use this script, follow these steps:

1. Save the script to a file, for example, `azure_setup.sh`.

2. Make the script executable by running `chmod +x azure_setup.sh`.

3. Run the script with your desired subscription ID as an argument:

```
Bash

./azure_setup.sh <subscriptionId>

```

Replace `<subscriptionId>` with your actual Azure subscription ID.
