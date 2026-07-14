from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse

from app.core.config import settings
from app.routers import articles, auth, face, search, trends, users, assessment, chatbot, journal

app = FastAPI(
    title=settings.APP_TITLE,
    description=(
        "API MindTrack — Mental Health App\n\n"
        "**Cara pakai Swagger:**\n"
        "1. Login via `POST /auth/login` atau `POST /auth/google`\n"
        "2. Copy `access_token` dari response\n"
        "3. Klik **Authorize** → paste token → **Authorize**"
    ),
    version=settings.APP_VERSION,
    swagger_ui_parameters={"persistAuthorization": True},
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(users.router)
app.include_router(articles.router)
app.include_router(trends.router)
app.include_router(search.router)
app.include_router(assessment.router)
app.include_router(chatbot.router)
app.include_router(face.router)
app.include_router(journal.router)


@app.get("/", tags=["Root"])
def root():
    return {
        "message": "MindTrack API Running",
        "docs": "/docs",
        "redoc": "/redoc",
    }


@app.get("/privacy-policy", response_class=HTMLResponse, tags=["Legal"])
def privacy_policy():
    html = """
    <!DOCTYPE html>
    <html lang="id">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Kebijakan Privasi - MindTrack</title>
        <style>
            body { font-family: Arial, sans-serif; max-width: 800px; margin: 40px auto; padding: 0 20px; color: #333; line-height: 1.7; }
            h1 { color: #4A90D9; border-bottom: 2px solid #4A90D9; padding-bottom: 10px; }
            h2 { color: #2c3e50; margin-top: 30px; }
            p { margin: 10px 0; }
            ul { padding-left: 20px; }
            .last-updated { color: #888; font-size: 0.9em; }
        </style>
    </head>
    <body>
        <h1>Kebijakan Privasi MindTrack</h1>
        <p class="last-updated">Terakhir diperbarui: 15 Juli 2026</p>

        <p>MindTrack ("kami", "aplikasi") berkomitmen untuk melindungi privasi seluruh pengguna. Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, menyimpan, dan melindungi informasi pribadi Anda saat menggunakan aplikasi MindTrack.</p>

        <h2>1. Informasi yang Kami Kumpulkan</h2>
        <p>Kami mengumpulkan informasi berikut ketika Anda mendaftar dan menggunakan MindTrack:</p>
        <ul>
            <li>Nama lengkap dan alamat email</li>
            <li>Data foto wajah (digunakan hanya untuk fitur autentikasi login biometrik)</li>
            <li>Data audio suara (digunakan untuk fitur speech-to-text pada chatbot)</li>
            <li>Hasil asesmen kesehatan mental</li>
            <li>Jurnal dan catatan pribadi yang Anda isi</li>
            <li>Data aktivitas dan penggunaan dalam aplikasi</li>
        </ul>

        <h2>2. Cara Penggunaan Data</h2>
        <p>Data yang kami kumpulkan digunakan untuk:</p>
        <ul>
            <li>Membuat dan mengelola akun pengguna</li>
            <li>Mengautentikasi identitas pengguna melalui teknologi pengenalan wajah</li>
            <li>Menyimpan dan menampilkan riwayat asesmen serta progres kesehatan mental Anda</li>
            <li>Memberikan respons yang personal dan relevan melalui fitur Chatbot AI</li>
            <li>Meningkatkan kualitas layanan dan fitur aplikasi</li>
        </ul>

        <h2>3. Penyimpanan dan Keamanan Data</h2>
        <p>Seluruh data pengguna disimpan di server yang aman dengan enkripsi selama proses transmisi (HTTPS). Kami menerapkan langkah-langkah teknis yang memadai untuk melindungi data Anda dari akses yang tidak sah, perubahan, pengungkapan, atau penghapusan.</p>

        <h2>4. Berbagi Data dengan Pihak Ketiga</h2>
        <p>Kami <strong>tidak menjual, menyewakan, atau membagikan</strong> data pribadi Anda kepada pihak ketiga mana pun tanpa persetujuan eksplisit Anda, kecuali diwajibkan oleh hukum yang berlaku.</p>

        <h2>5. Hak Pengguna</h2>
        <p>Sebagai pengguna MindTrack, Anda memiliki hak untuk:</p>
        <ul>
            <li>Mengakses dan melihat data pribadi yang kami simpan</li>
            <li>Meminta koreksi atas data yang tidak akurat</li>
            <li>Meminta penghapusan akun beserta seluruh data pribadi Anda</li>
            <li>Mengajukan pertanyaan atau keluhan terkait privasi</li>
        </ul>

        <h2>6. Perubahan Kebijakan Privasi</h2>
        <p>Kami dapat memperbarui Kebijakan Privasi ini sewaktu-waktu. Setiap perubahan yang signifikan akan diberitahukan kepada pengguna melalui notifikasi di dalam aplikasi. Dengan terus menggunakan aplikasi setelah perubahan diberlakukan, Anda dianggap menyetujui kebijakan yang telah diperbarui.</p>

        <h2>7. Hubungi Kami</h2>
        <p>Jika Anda memiliki pertanyaan, kekhawatiran, atau permintaan terkait kebijakan privasi ini, silakan hubungi kami melalui email yang terdaftar pada akun Anda di aplikasi MindTrack.</p>

        <br>
        <p>Dengan mendaftar dan menggunakan MindTrack, Anda menyatakan telah membaca, memahami, dan menyetujui Kebijakan Privasi ini.</p>
    </body>
    </html>
    """
    return html
