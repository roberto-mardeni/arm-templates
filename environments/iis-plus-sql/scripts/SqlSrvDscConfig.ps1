Configuration Main
{
  Param ( [string] $nodeName )

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
  $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $nodeName

  # Change authentication mode to mixed
  $server.Settings.LoginMode = "Mixed"
  $server.Alter()

  # Restart SQL Service, think this is needed to pickup the security mode change
  Restart-Service MSSQLSERVER -Force

  Import-DscResource -ModuleName PSDesiredStateConfiguration
  Import-DscResource -ModuleName xSqlServer

  Node $nodeName
  {
    xSqlServerFirewall($nodeName) {
      SourcePath   = "C:\SQLServerFull"
      InstanceName = "MSSQLSERVER"
      Features     = "SQLENGINE"
    }
  }
}