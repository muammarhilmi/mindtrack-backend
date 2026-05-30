@echo off
cd /d %~dp0
call venv\Scripts\activate.bat
echo MindTrack API: http://127.0.0.1:5000/docs
uvicorn app.main:app --reload --host 127.0.0.1 --port 5000
