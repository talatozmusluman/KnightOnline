param(
	[switch]$Force
)

$ErrorActionPreference = "Stop"

$names = @(
	"AIServer",
	"Ebenezer",
	"Aujard",
	"ItemManager",
	"VersionManager",
	"KnightOnLine"
)

foreach ($name in $names) {
	$procs = Get-Process -Name $name -ErrorAction SilentlyContinue
	if ($null -eq $procs) { continue }

	foreach ($p in $procs) {
		try {
			if ($Force) {
				Stop-Process -Id $p.Id -Force -ErrorAction Stop
			}
			else {
				Stop-Process -Id $p.Id -ErrorAction Stop
			}
		}
		catch {
			Write-Warning "Failed to stop $name (pid=$($p.Id)): $($_.Exception.Message)"
		}
	}
}

