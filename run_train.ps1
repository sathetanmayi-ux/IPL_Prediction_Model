param(
    [switch]$SkipDl
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
$python = "C:/Users/shivk/AppData/Local/Programs/Python/Python314/python.exe"

if ($SkipDl) {
    & $python train.py --skip-dl
} else {
    & $python train.py
}
