cd backend
venv\Scripts\activate
uvicorn app.main:app --reload --host 127.0.0.1 --port 5000

cd frontend
flutter run -d chrome --web-port=8080
