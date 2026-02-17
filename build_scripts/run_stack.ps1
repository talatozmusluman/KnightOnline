param(
	[ValidateSet("Debug-x64", "Release-x64")]
	[string]$Bin = "Debug-x64",

	[switch]$StartVersionManager,
	[switch]$StartClient,

	[string]$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"

function Get-IniValue {
	param(
		[Parameter(Mandatory = $true)][string]$Path,
		[Parameter(Mandatory = $true)][string]$Section,
		[Parameter(Mandatory = $true)][string]$Key,
		[string]$Default = ""
	)

	$inSection = $false
	foreach ($line in Get-Content -LiteralPath $Path) {
		$trim = $line.Trim()
		if ($trim.Length -eq 0) { continue }
		if ($trim.StartsWith(";") -or $trim.StartsWith("#")) { continue }

		if ($trim.StartsWith("[") -and $trim.EndsWith("]")) {
			$inSection = ($trim.Substring(1, $trim.Length - 2) -ieq $Section)
			continue
		}

		if (-not $inSection) { continue }

		$parts = $trim.Split("=", 2)
		if ($parts.Count -ne 2) { continue }
		if ($parts[0].Trim() -ieq $Key) {
			return $parts[1].Trim()
		}
	}

	return $Default
}

function Wait-ForPort {
	param(
		[Parameter(Mandatory = $true)][int]$Port,
		[string]$HostName = "127.0.0.1",
		[int]$TimeoutSeconds = 20
	)

	$deadline = (Get-Date).AddSeconds($TimeoutSeconds)
	while ((Get-Date) -lt $deadline) {
		try {
			$ok = Test-NetConnection -ComputerName $HostName -Port $Port -InformationLevel Quiet -WarningAction SilentlyContinue
			if ($ok) { return $true }
		}
		catch {
		}

		Start-Sleep -Milliseconds 250
	}

	return $false
}

$binDir = Join-Path $Root ("bin\" + $Bin)
if (-not (Test-Path -LiteralPath $binDir)) {
	throw "Bin directory not found: $binDir"
}

$serverIni = Join-Path $binDir "server.ini"
$gameIni = Join-Path $binDir "gameserver.ini"

if (-not (Test-Path -LiteralPath $serverIni)) { throw "Missing: $serverIni" }
if (-not (Test-Path -LiteralPath $gameIni)) { throw "Missing: $gameIni" }

$mapDir = Join-Path $Root "assets\\Server\\MAP"
if (-not (Test-Path -LiteralPath $mapDir)) {
	$mapDir = Join-Path $Root "bin\\Map"
}
if (-not (Test-Path -LiteralPath $mapDir)) {
	throw "Map directory not found (expected bin\\Map or assets\\Server\\MAP under repo): $mapDir"
}

$questsDir = Join-Path $Root "assets\\Server\\QUESTS"
if (-not (Test-Path -LiteralPath $questsDir)) {
	$questsDir = Join-Path $Root "bin\\QUESTS"
}
if (-not (Test-Path -LiteralPath $questsDir)) {
	throw "Quests directory not found (expected assets\\Server\\QUESTS or bin\\QUESTS under repo): $questsDir"
}

$aiZoneType = [int](Get-IniValue -Path $serverIni -Section "SERVER" -Key "ZONE" -Default "1")
$aiPort =
	switch ($aiZoneType) {
		0 { 10020 }
		1 { 10020 }
		2 { 10030 }
		3 { 10040 }
		default { 10020 }
	}

$serverNo = [int](Get-IniValue -Path $gameIni -Section "ZONE_INFO" -Key "MY_INFO" -Default "1")
$ebenezerPort = 15000 + $serverNo

$aiserverExe = Join-Path $binDir "AIServer.exe"
$ebenezerExe = Join-Path $binDir "Ebenezer.exe"
$aujardExe = Join-Path $binDir "Aujard.exe"
$itemManagerExe = Join-Path $binDir "ItemManager.exe"
$versionManagerExe = Join-Path $binDir "VersionManager.exe"
$clientExe = Join-Path $binDir "KnightOnLine.exe"
$clientAssetsDir = Join-Path $Root "assets\\Client"

foreach ($exe in @($aiserverExe, $ebenezerExe, $aujardExe, $itemManagerExe)) {
	if (-not (Test-Path -LiteralPath $exe)) { throw "Missing: $exe" }
}

Write-Host "Starting AIServer (zone=$aiZoneType port=$aiPort)..." -ForegroundColor Cyan
Start-Process -FilePath $aiserverExe -WorkingDirectory $binDir -ArgumentList @("--map-dir", $mapDir, "--event-dir", $mapDir) | Out-Null
if (-not (Wait-ForPort -Port $aiPort -TimeoutSeconds 25)) {
	Write-Warning "AIServer port $aiPort did not open within timeout. Check logs in $binDir\\logs\\AIServer.log"
}

Write-Host "Starting Ebenezer (port=$ebenezerPort)..." -ForegroundColor Cyan
Start-Process -FilePath $ebenezerExe -WorkingDirectory $binDir -ArgumentList @("--map-dir", $mapDir, "--quests-dir", $questsDir) | Out-Null
if (-not (Wait-ForPort -Port $ebenezerPort -TimeoutSeconds 25)) {
	Write-Warning "Ebenezer port $ebenezerPort did not open within timeout. Check logs in $binDir\\logs\\Ebenezer.log"
}

Write-Host "Starting Aujard + ItemManager..." -ForegroundColor Cyan
Start-Process -FilePath $aujardExe -WorkingDirectory $binDir | Out-Null
Start-Process -FilePath $itemManagerExe -WorkingDirectory $binDir | Out-Null

if ($StartVersionManager) {
	if (-not (Test-Path -LiteralPath $versionManagerExe)) { throw "Missing: $versionManagerExe" }
	Write-Host "Starting VersionManager (port=15100)..." -ForegroundColor Cyan
	Start-Process -FilePath $versionManagerExe -WorkingDirectory $binDir | Out-Null
}

if ($StartClient) {
	if (-not (Test-Path -LiteralPath $clientExe)) { throw "Missing: $clientExe" }
	if (-not (Test-Path -LiteralPath $clientAssetsDir)) { throw "Missing: $clientAssetsDir" }
	Write-Host "Starting client..." -ForegroundColor Cyan
	# Client assets are loaded relative to working directory (e.g. Data\\*.tbl, UI\\*, etc.)
	# so use assets\\Client as the working directory.
	Start-Process -FilePath $clientExe -WorkingDirectory $clientAssetsDir | Out-Null
}

Write-Host "Done. Logs: $binDir\\logs" -ForegroundColor Green
