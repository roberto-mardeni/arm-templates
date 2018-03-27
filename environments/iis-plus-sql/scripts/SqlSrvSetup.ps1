[CmdletBinding()]
param
(
    [Parameter(Mandatory = $true)]
    [string] $HostName
)

###################################################################################################
#
# PowerShell configurations
#

# NOTE: Because the $ErrorActionPreference is "Stop", this script will stop on first failure.
#       This is necessary to ensure we capture errors inside the try-catch-finally block.
$ErrorActionPreference = "Stop"

# Ensure we set the working directory to that of the script.
Push-Location $PSScriptRoot

.\config-winrm.ps1 $HostName

# Install Nuget, needed to install DSC modules via PowerShellGet
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Install DSC modules used by DSC Scripts run via DSC Extension
# - Note, was told this is not a best practice.  It was suggested
# - that the module should be zipped with the script, downloaded
# - then installed.  This is to ensure you have the same version 
# - of the module to prevent your script from breaking.
Install-Module -name xSqlServer -Force

# Import SQL Server module
Import-Module SQLPS -DisableNameChecking

# Create SQL Server Object
$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $ENV:COMPUTERNAME
# Change authentication mode to mixed
$server.Settings.LoginMode = "Mixed"
$server.Alter()

# Restart SQL Service, think this is needed to pickup the security mode change
Restart-Service MSSQLSERVER -Force