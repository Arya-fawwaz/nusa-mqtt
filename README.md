# Nusa Power IoT & AI System ????

Selamat datang di repositori resmi **Nusa Power**, sistem cerdas penghemat baterai dan pemantauan energi surya (PLTS) berbasis Internet of Things (IoT) dan Artificial Intelligence (AI).

## ?? Fitur Utama
1. **Nusa AI Engine**: Algoritma cerdas di backend yang secara otomatis memutus atau menyambungkan relay (beban) berdasarkan sisa baterai (SOC) dan daya matahari yang masuk. 
2. **Real-time Monitoring**: Memantau tegangan, arus baterai, dan daya panel surya secara *real-time* lewat protokol MQTT.
3. **Mobile App (Flutter)**: Aplikasi Android/iOS untuk mengontrol alat secara manual maupun beralih ke mode otomatis (AI Mode).
4. **Cloud Ready**: Backend diatur agar mudah di-deploy ke Vercel (untuk API) dan Render.com/Koyeb (untuk Background Worker MQTT).

## ?? Struktur Direktori
- ackend/: Berisi program Python (FastAPI & aiomqtt).
  - main.py: REST API untuk aplikasi mobile (Login, Update Profil, Status Relay).
  - mqtt_client.py: Worker AI yang berjalan 24/7 mendengarkan data sensor via MQTT dan mengambil keputusan otomatis.
  - Dockerfile: Konfigurasi *container* untuk deployment backend ke cloud.
- mobile/: Berisi source code aplikasi Android berbasis Flutter.
  - lib/main.dart: Halaman utama aplikasi (UI).

## ?? Cara Deploy ke Render.com (Backend MQTT)
1. Buat **Web Service** baru di Render.
2. Hubungkan ke repositori ini.
3. Pada bagian **Root Directory**, isi dengan: ackend
4. Pilih **Free Tier**, lalu klik Deploy!

