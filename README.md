# AnyPackage.Winget
AnyPackage.Winget is an AnyPackage provider that facilitates installing Winget packages from any NuGet repository.

## Install AnyPackage.Winget
```PowerShell
Install-Module AnyPackage.Winget -Force
```

## Import AnyPackage.Winget
```PowerShell
Import-Module AnyPackage.Winget
```

## Sample usages

### Search for a package
```PowerShell
Find-Package -Name nodejs

Find-Package -Name firefox*
```

### Install a package
```PowerShell
Find-Package nodejs | Install-Package

Install-Package -Name 7zip
```

### Get list of installed packages
```PowerShell
Get-Package nodejs
```

### Uninstall a package
```PowerShell
Get-Package keepass-plugin-winhello | Uninstall-Package
```

### Manage package sources
```PowerShell
Register-PackageSource privateRepo -Provider Winget -Location 'https://somewhere/out/there/api/v2/'
Find-Package nodejs -Source privateRepo | Install-Package
Unregister-PackageSource privateRepo
```
AnyPackage.Winget integrates with Winget.exe to manage and store source information

## Known Issues
### Compatibility
AnyPackage.Winget works with PowerShell for both FullCLR/'Desktop' (ex 5.1) and CoreCLR (ex: 7.0.1), though Winget itself still requires FullCLR.

Users must upgrade to v0.1.0 or higher of this provider module prior to the release of Winget v2 to ensure continued compatibility.

### Save a package
Save-Package is not supported with the AnyPackage.Winget provider, due to Winget not supporting package downloads without special licensing.

## Legal and Licensing
AnyPackage.Winget is licensed under the [MIT license](./LICENSE.txt).
