$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
$python = "C:/Users/shivk/AppData/Local/Programs/Python/Python314/python.exe"
& $python -m streamlit run app.py --server.headless true --server.port 8501 --server.fileWatcherType none
