<#
.SYNOPSIS
    Disable an Internal User in Cisco ISE via ERS API.
    
.DESCRIPTION
    This script connects to Cisco ISE External RESTful Services (ERS) API,
    locates an Internal User by name, and sets their status to "Disabled".
    
.NOTES
    Author: 2DTECHBG
    Version: 1.0
    Requirements: ERS Admin privileges in Cisco ISE, Port 9060 enabled.
#>

# --- [ CONFIGURATION ] ---
$ISE_IP   = "CISCO_ISE_IP"
$ISE_Port = "9060"
$AdminUser = "ERS_ADMIN_USERNAME"
$AdminPass = "ERS_ADMIN_PASSWORD"

# --- [ SSL HANDLING ] ---
# Bypass SSL certificate validation (Warning: Only for lab/testing environments!)
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

function Disable-ISEInternalUser {
    param (
        [Parameter(Mandatory=$true)]
        [string]$TargetUsername
    )

    Write-Host "--- Starting Process for User: $TargetUsername ---" -ForegroundColor Cyan

    # 1. Setup Authentication Headers
    $authPair = "${AdminUser}:${AdminPass}"
    $encodedAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($authPair))
    
    $headers = @{
        "Authorization" = "Basic $encodedAuth"
        "Accept"        = "application/json"
        "Content-Type"  = "application/json"
    }

    try {
        # 2. Search for User to get their unique ID
        $searchUri = "https://$($ISE_IP):$ISE_Port/ers/config/internaluser?filter=name.EQ.$TargetUsername"
        $searchResponse = Invoke-RestMethod -Uri $searchUri -Headers $headers -Method Get
        
        $userID = $searchResponse.SearchResult.resources.id

        if (-not $userID) {
            Write-Host "[!] Error: User '$TargetUsername' not found in Cisco ISE." -ForegroundColor Red
            return
        }

        Write-Host "[+] Found User ID: $userID" -ForegroundColor Green

        # 3. Retrieve current user object (Required to maintain mandatory fields during PUT)
        $userUri = "https://$($ISE_IP):$ISE_Port/ers/config/internaluser/$userID"
        $userObj = Invoke-RestMethod -Uri $userUri -Headers $headers -Method Get

        # 4. Construct JSON Body for disabling the user
        # Note: ERS PUT requests require 'id', 'name' and the updated attributes.
        $body = @{
            InternalUser = @{
                id      = $userID
                name    = $userObj.InternalUser.name
                enabled = $false
            }
        } | ConvertTo-Json -Depth 5

        # 5. Execute the Update (PUT)
        Write-Host "[*] Sending request to disable user..." -ForegroundColor Yellow
        $updateResponse = Invoke-RestMethod -Uri $userUri -Method Put -Headers $headers -Body $body
        
        Write-Host "[✔] Success: User '$TargetUsername' has been disabled." -ForegroundColor Green
    }
    catch {
        Write-Host "[X] Fatal Error: $($_.Exception.Message)" -ForegroundColor Red
        
        # Extract detailed API error if available
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $details = $reader.ReadToEnd()
            Write-Host "API Details: $details" -ForegroundColor Yellow
        }
    }
}

# --- [ EXECUTION ] ---
# Define the Internal user you want to disable
$target = "test"

# Run the function
Disable-ISEInternalUser -TargetUsername $target