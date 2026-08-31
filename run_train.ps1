$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
$python = "C:/Users/shivk/AppData/Local/Programs/Python/Python314/python.exe"

& $python train.py
