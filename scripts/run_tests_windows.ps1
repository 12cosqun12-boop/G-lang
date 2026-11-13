$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$G = Join-Path $Root "bin\windows-x86_64\g.exe"
$Build = Join-Path $Root "build-windows"
New-Item -ItemType Directory -Force -Path $Build | Out-Null
$failed = $false
Get-ChildItem (Join-Path $Root "tests\*.g") | ForEach-Object {
    $name = $_.BaseName
    $exe = Join-Path $Build ($name + ".exe")
    & $G $_.FullName $exe
    $argsFile = Join-Path $Root ("tests\" + $name + ".args")
    if (Test-Path $argsFile) {
        $args = (Get-Content $argsFile -Raw).Trim().Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)
        $actual = & $exe @args | Out-String
    } else {
        $actual = & $exe | Out-String
    }
    $actualPath = Join-Path $Build ($name + ".actual")
    [IO.File]::WriteAllText($actualPath, $actual.Replace("`r`n", "`n"))
    $expected = [IO.File]::ReadAllText((Join-Path $Root ("tests\" + $name + ".expected"))).Replace("`r`n", "`n")
    $got = [IO.File]::ReadAllText($actualPath)
    if ($got -eq $expected) { Write-Host "PASS $name" } else { Write-Host "FAIL $name"; $failed = $true }
}
if ($failed) { exit 1 }
