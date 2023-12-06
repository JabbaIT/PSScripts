<# 
    .SYNOPSIS
    This script generates the Windows Update log and checks for errors.

    .DESCRIPTION
    This script generates the Windows Update log and checks for errors.

    .EXAMPLE
        PS C:\> .\Get-WindowsUpdateErrors.ps1

   .NOTES
    =================================
        Author: Jamie Price
        Date: 05/12/2023
        FileName: Get-WindowsUpdateErrors.ps1        
        Version History:
            1.0 - 05/12/2023 - Initial release
    =================================
    
#>

#Requires -RunAsAdministrator

[cmdletbinding()]
param(
)

# Generate the Windows Update log
Get-WindowsUpdateLog -LogPath "$($env:userprofile)\Desktop\WindowsUpdate.log"

# Read the log file
$logContent = Get-Content -Path "$($env:userprofile)\Desktop\WindowsUpdate.log"

# Check for errors
$errors = $logContent | Select-String -Pattern "ERROR"

# If there are errors, print them
if ($errors) {
    Write-Output "Found the following Windows Update errors:"
    Write-Output $errors
} else {
    Write-Output "No Windows Update errors found."
}