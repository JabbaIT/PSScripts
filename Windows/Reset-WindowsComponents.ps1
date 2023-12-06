<#
    .SYNOPSIS
        This script will reset Windows Update components.

    .DESCRIPTION
        This script will reset Windows Update components.
    
    .NOTES
    =================================
        Author: Jamie Price
        Date: 05/12/2023
        FileName: Reset-WindowsComponents.ps1        
        Version History:
            1.0 - 05/12/2023 - Initial release
    =================================

#>

#Requires -RunAsAdministrator

[cmdletbinding()]
param(    
)

try {

    Write-Host "Stopping WUAUSERV service" -ForegroundColor Yellow
    Stop-Service wuauserv -ErrorAction Stop
    Write-Host "Stopped WUAUSERV service" -ForegroundColor Green

    Write-Host "Stopping cryptSvc service" -ForegroundColor Yellow
    Stop-Service cryptSvc -ErrorAction Stop
    Write-Host "Stopped cryptSvc service" -ForegroundColor Green

    Write-Host "Stopping bits service" -ForegroundColor Yellow
    Stop-Service bits -ErrorAction Stop
    Write-Host "Stopped bits service" -ForegroundColor Green

    Write-Host "Stopping msiserver service" -ForegroundColor Yellow
    Stop-Service msiserver -ErrorAction Stop
    Write-Host "Stopped msiserver service" -ForegroundColor Green
}
catch {
    Write-Error -Message "Failed to stop services. Please start the service manually." -Category InvalidOperation
    return
}

try {

    Write-Host "Renaming C:\Windows\SoftwareDistribution folder" -ForegroundColor Yellow
    Move-item -Path "C:\Windows\SoftwareDistribution" -Destination "C:\Windows\SoftwareDistribution.old" -Force -Confirm:$false -ErrorAction Stop

    Write-Host "Renaming C:\Windows\System32\catroot2 folder" -ForegroundColor Yellow
    Move-item -Path "C:\Windows\System32\catroot2" -Destination "C:\Windows\System32\catroot2.old" -Force -Confirm:$false -ErrorAction Stop
}
catch {
    Write-Error -Message "Failed to move folders. Please move the folders manually." -Category InvalidOperation
    return
}

try {
    Write-Host "Starting WUAUSERV service" -ForegroundColor Yellow
    Start-Service wuauserv -ErrorAction Stop
    Write-Host "Started WUAUSERV service" -ForegroundColor Green

    Write-Host "Starting CRYPTSVC service" -ForegroundColor Yellow
    Start-Service cryptSvc -ErrorAction Stop
    Write-Host "Started CRYPTSVC service" -ForegroundColor Green

    Write-Host "Starting bits service" -ForegroundColor Yellow
    Start-Service bits -ErrorAction Stop
    Write-Host "Started bits service" -ForegroundColor Green

    Write-Host "Starting msiserver Service" -ForegroundColor Yellow
    Start-Service msiserver -ErrorAction Stop
    Write-Host "Started msiserver Service" -ForegroundColor Green
}
catch {
    Write-Error -Message "Failed to start services. Please start the service manually." -Category InvalidOperation
    return
}
