# ciscoiseautomat
PowerShell sciprts for Cisco ISE ERS automation
Cisco ISE: Disable Internal Users via ERS API & PowerShell
This repository contains a professional PowerShell script designed to automate the process of disabling Internal Users in Cisco Identity Services Engine (ISE) using the External RESTful Services (ERS) API.

🚀 Overview
Manually managing users in Cisco ISE can be tedious, especially in large environments. This script allows network administrators to:

Search for a user by their username.

Retrieve the unique User ID from the ISE database.

Disable the user account programmatically.

This is ideal for integration with employee offboarding workflows or helpdesk automation.

🛠 Prerequisites
Before running the script, ensure the following requirements are met:

1. Enable ERS API in Cisco ISE
By default, the ERS API is disabled. To enable it:

Navigate to Administration > System > Settings > ERS Settings.

Select Enable ERS Read/Write.

Click Save.

2. Admin Permissions
The credentials used in the script must belong to an admin account that is part of the ERS Admin or ERS Operator group.

Go to Administration > System > Admin Access > Administrators > Admin Users.

3. Network Access
The machine running the script must have HTTPS access to the Cisco ISE PAN (Policy Administration Node) on TCP Port 9060.

💻 Usage
Clone the repository:

Bash
git clone https://github.com/2dtechbg-mrr/ciscoiseautomat/blob/main/ise_v1.ps1

Edit the Configuration section in the .ps1 script:

PowerShell
$ISE_IP   = "192.168.1.201"
$AdminUser = "your_admin_user"
$AdminPass = "your_password"
Run the script:

PowerShell
.\Disable-ISEUser.ps1

⚠️ Security Note
[!IMPORTANT]
The current version of the script includes a bypass for SSL certificate validation (TrustAllCertsPolicy). This is intended for lab environments or testing with self-signed certificates. For production environments, it is highly recommended to use trusted CA-signed certificates and remove the SSL bypass block.

📜 Script Logic Flow
Auth: Encodes credentials into a Base64 string for Basic Authentication.

GET (Filter): Queries /ers/config/internaluser?filter=name.EQ.username to find the Resource ID.

GET (Details): Fetches the full user object (required to satisfy ISE mandatory fields during update).

PUT: Sends a JSON payload to /ers/config/internaluser/{id} with "enabled": false.

🤝 Contributing
Feel free to fork this project, open issues, or submit pull requests for any improvements!

Author: 2DTECHBG

YouTube Tutorial: https://www.youtube.com/watch?v=NeBcMymb5l0
