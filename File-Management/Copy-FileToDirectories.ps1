<#
	.SYNOPSIS
		Copy file to Sub Directories
	
	.DESCRIPTION
		This script will copy specified Source File and copy to the sub directories under the Destination Folder
	
	.PARAMETER SrcFile
		The UNC Path or Path to the Source Folder & File
	
	.PARAMETER DestDir
		The UNC Path or Path to the Destionation Folder
	
	.PARAMETER Overwrite
		Switch to overwrite the file if already exists
	
	.PARAMETER OutputToCSV
		A description of the OutputToCSV parameter.
	
	.PARAMETER OutputErrors
		Output to Console the Errors that have occurred
	
	.PARAMETER OutputToConsole
		Output to Console full results
	
	.PARAMETER OutputCSVPath
		Output to CSV File full results
	
	.EXAMPLE
		.\Copy-FileToDirectories.ps1
	
	.EXAMPLE
		.\Copy-FileToDirectories.ps1 -Overwite
		This will overwrite the file if already exists

	.EXAMPLE
		.\Copy-FileToDirectories.ps1 -OutputToConsole
		This output full results to the console

	.EXAMPLE
		.\Copy-FileToDirectories.ps1 -OutputToCSV -OutputToCSVPath "x:\OutputFolder"
		This will output the full results to CSV file in specified directory
	
	.NOTES
		===========================================================================
		Created on:   	16/11/2023 19:07
		Created by:   	Jamie Price
		Filename:		Copy-FileToDirectories.ps1
		Version: 		1.0
		===========================================================================
#>
[CmdletBinding()]
param
(
	[Parameter(Position = 1)]
	[string]$SrcFile = "E:\BaseDir\TestDoc.docx",
	[Parameter(Position = 2)]
	[string]$DestDir = "E:\DestDir",
	[Parameter(Position = 3)]
	[switch]$Overwrite,
	[Parameter(Position = 4)]
	[switch]$OutputToCSV,
	[Parameter(Position = 5)]
	[switch]$OutputErrors,
	[Parameter(Position = 6)]
	[Switch]$OutputToConsole,
	[Parameter(Position = 7)]
	[string]$OutputCSVPath
)

# DataTable for Results
$dt = New-Object System.Data.DataTable
$dt.Columns.Add("Destination") | Out-Null
$dt.Columns.Add("Action") | Out-Null

# Variables 
$file = [System.IO.Path]::GetFileName($SrcFile)

Write-Verbose -Message "Checking Source Path $($SrcFile)"
if ((Test-Path -Path $SrcFile) -eq $false)
{
	Write-Error -Message "Source File $($SrcFile) cannot be found, please check" -Category ObjectNotFound
	return
}

Write-Verbose -Message "checking Destination Directory $($DestDir) is present"
if ((Test-Path -Path $DestDir) -eq $false)
{
	Write-Error -Message "Destination Folder Root $($DestDir) cannot be found, please check that folder is present" -Category ObjectNotFound
	return
}

Write-Verbose -Message "Collating a list of the Directories"
$directories = Get-ChildItem -Path $($DestDir) -Directory

Write-Verbose -Message "Check & Copy file to $($DestDir)"
foreach ($directory in $directories)
{
	
	# Clear Variables
	$destDirPath = $null
	$fileAlreadyExist = $null
	
	# Loop Variables 
	$destDirPath = "$($directory)\$($file)"
	
	
	# Does the File already Exist
	if ((Test-Path -Path "$($destDirPath)"))
	{
		# The file does not exist
		$fileAlreadyExist = $false
	}
	else
	{
		# The file already exists
		$fileAlreadyExist = $true
	}
	
	# Copy the file to the directory
	if ($fileAlreadyExist -eq $false)
	{
		$fileAlreadyExist
		try
		{
			Write-Verbose -Message "Copying $($SrcFile) to $($directory.FullName)\$($file)"
			Copy-Item -Path $($SrcFile) -Destination "$($directory.FullName)\$($file)" -Confirm:$false
			
			$dt.Rows.Add(
				"$($directory.FullName)\$($file)",
				"Copied"
			)
		}
		catch
		{
			$dt.Rows.Add(
				"$($directory.FullName)\$($file)",
				"Error"
			) | Out-Null
		}
	}
	elseif ($fileAlreadyExist -eq $true -and $Overwrite -eq $true)
	{
		try
		{
			Write-Verbose -Message "Overwriting $($SrcFile) to $($directory.FullName)\$($file)"
			Copy-Item -Path $($SrcFile) -Destination "$($directory.FullName)\$($file)" -Confirm:$false
			
			$dt.Rows.Add(
				"$($directory.FullName)\$($file)",
				"Overwritten"
			) | Out-Null
		}
		catch
		{
			$dt.Rows.Add(
				"$($directory.FullName)\$($file)",
				"Error"
			) | Out-Null
		}
	}
	else
	{
		$dt.Rows.Add(
			"$($directory.FullName)\$($file)",
			"No Action"
		) | Out-Null
	}
	
}

if ($OutputToConsole)
{
	Write-Verbose -Message "Outputting Full Results to Console"
	$dt | Format-Table
}

if ($OutputErrors)
{
	Write-Verbose -Message "Outputting Errors to Console"
	$dt | Where-Object {$_.Action -eq "Error"} | Format-Table
}

if ($OutputToCSV -eq $true) {
		
	Write-Verbose -Message "Exporting results to CSV File"
	
	Write-Verbose -Message "Checking if Output Folder for CSV has been provided"
	if (!$OutputCSVPath)
	{
		$OutputCSVPath = Read-Host -Prompt "Please Enter in Path to Export Output File C:\OutputExample\"
	}	

	If (!(Test-Path -Path $OutputCSVPath))
	{
		try
		{
			Write-Verbose -Message "Creating Folder $($OutputCSVPath)"
			New-Item -Path $OutputCSVPath -ItemType Directory -Force -ErrorAction Stop
		}
		catch
		{
			Write-Error -Message "Failed to Create Directory $($OutputCSVPath)" -Category InvalidOperation
			return
		}
	}
			
	try
	{
		Write-Verbose -Message "Exporting Result to CSV File in $($OutputCSVPath)"
		$dt | Export-Csv -Path "$($OutputCSVPath)\Export-$(Get-Date -Format 'dd-MM-yy-HH-mm-ss').csv" -NoTypeInformation -NoClobber -ErrorAction Stop		
	}
	catch
	{
		Write-Error -Message "Failed to Create Export $($OutputToCSV)\Export-$(Get-Date -Format "dd-MM-yy-HH:mm:ss").csv" -Category DeviceError
		return
	}
}

Write-Host "Script Completed" -ForegroundColor Green
