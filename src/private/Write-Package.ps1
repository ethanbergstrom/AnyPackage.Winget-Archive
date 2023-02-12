function Write-Package {
	param (
		[Parameter(ValueFromPipeline)]
		[object[]]
		$InputObject,

		[Parameter()]
		[PackageRequest]
		$Request = $Request
	)

	process {
		foreach ($package in $InputObject) {
			if ($package.Source) {
				# If source information is provided, construct a source object for inclusion in the results
				$source = $Request.NewSourceInfo($package.Source,(Cobalt\Get-WingetSource | Where-Object Name -EQ $package.Source | Select-Object -ExpandProperty Location),$true)
				$Request.WritePackage($package.ID, $package.Version, '', $source)
			} else {
				$Request.WritePackage($package.ID, $package.Version)
			}
		}
	}
}