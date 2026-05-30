Set-Location $PSScriptRoot
& .\venv\Scripts\Activate.ps1
Write-Host "MindTrack API: http://127.0.0.1:5000/docs" -ForegroundColor Green
uvicorn app.main:app --reload --host 127.0.0.1 --port 5000
