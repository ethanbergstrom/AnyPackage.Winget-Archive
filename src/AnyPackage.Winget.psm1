using module AnyPackage
using namespace AnyPackage.Provider

# Current script path
[string]$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope Script).Value.MyCommand.Definition -Parent

# Dot sourcing private script files
Get-ChildItem $ScriptPath/private -Recurse -Filter '*.ps1' -File | ForEach-Object {
	. $_.FullName
}

class InstallPackageDynamicParameters {
	[Parameter()]
	[switch]
	$ParamsGlobal

	[Parameter()]
	[string]
	$Parameters
}

class UninstallPackageDynamicParameters {
	[Parameter()]
	[switch]
	$RemoveDependencies
}

[PackageProvider("Winget")]
class WingetProvider : PackageProvider, IGetSource, ISetSource, IGetPackage, IFindPackage, IInstallPackage, IUninstallPackage {
	WingetProvider() : base('070f2b8f-c7db-4566-9296-2f7cc9146bf0') { }

	[object] GetDynamicParameters([string] $commandName) {
		return $(switch ($commandName) {
			'Install-Package' {[InstallPackageDynamicParameters]::new()}
			'Uninstall-Package' {[UninstallPackageDynamicParameters]::new()}
			Default {$null}
		})
	}

	[void] GetSource([SourceRequest] $Request) {
		Cobalt\Get-WingetSource | Where-Object {$_.Disabled -eq 'False'} | Where-Object {$_.Name -Like $Request.Name} | ForEach-Object {
			$Request.WriteSource($_.Name, $_.Location, $true)
		}
	}

	[void] RegisterSource([SourceRequest] $Request) {
		Cobalt\Register-WingetSource -Name $Request.Name -Location $Request.Location
		# Winget doesn't return anything after source operations, so we make up our own output object
		$Request.WriteSource($Request.Name, $Request.Location.TrimEnd("\"), $Request.Trusted)
	}

	[void] UnregisterSource([SourceRequest] $Request) {
		Cobalt\Unregister-WingetSource -Name $Request.Name
		# Winget doesn't return anything after source operations, so we make up our own output object
		$Request.WriteSource($Request.Name, '')
	}

	[void] SetSource([SourceRequest] $Request) {
		$this.RegisterSource($Request)
	}

	[void] GetPackage([PackageRequest] $Request) {
		Get-WingetPackage | Write-Package
	}

	[void] FindPackage([PackageRequest] $Request) {
		Find-WingetPackage | Write-Package
	}

	[void] InstallPackage([PackageRequest] $Request) {
		$WingetParams = @{
			ParamsGlobal = $Request.DynamicParameters.ParamsGlobal
			Parameters = $Request.DynamicParameters.Parameters
		}

		# Run the package request first through Find-WingetPackage to determine which source to use, and filter by any version requirements
		Find-WingetPackage | Cobalt\Install-WingetPackage @WingetParams | Write-Package
	}

	[void] UninstallPackage([PackageRequest] $Request) {
		$WingetParams = @{
			RemoveDependencies = $Request.DynamicParameters.RemoveDependencies
		}

		# Run the package request first through Get-WingetPackage to filter by any version requirements
		Get-WingetPackage | Cobalt\Uninstall-WingetPackage @WingetParams | Write-Package
	}
}

[PackageProviderManager]::RegisterProvider([WingetProvider], $MyInvocation.MyCommand.ScriptBlock.Module)

