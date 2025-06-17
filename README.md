AltarLink: Aplikasi Mobile Manajemen Liturgi Misdinar 📱✨
AltarLink adalah aplikasi mobile inovatif yang dirancang untuk merevolusi manajemen aktivitas liturgi bagi Misdinar Gereja Katolik Maria Bunda Karmel, Paroki Tomang. Proyek ini bertujuan menciptakan ekosistem digital yang terintegrasi untuk efisiensi operasional dan penguatan komunitas.

🌟 Latar Belakang
Manajemen jadwal tugas yang padat, akses terbatas ke materi edukatif, dan potensi disorganisasi seringkali menjadi tantangan bagi para Misdinar. AltarLink hadir sebagai solusi digital untuk menyediakan platform terpusat yang mudah diakses untuk informasi, panduan, dan komunikasi, mendukung pelayanan liturgi yang lebih terorganisir dan berkualitas.

✨ Fitur Utama
Untuk Misdinar (Pengguna):
🔑 Manajemen Akun: Registrasi, Login, Profil & Reset Kata Sandi.
🗓️ Jadwal Misa: Melihat jadwal pelayanan misa yang akan datang.
✅ Konfirmasi Kehadiran (Scan QR): Fungsionalitas parsial karena kendala backend - lihat bagian Status Proyek.
📚 Materi Pembelajaran: Akses materi edukatif dan informasi liturgi.
🔔 Notifikasi: Menerima pengumuman penting dari Admin.
📰 Postingan Komunitas: Melihat dan membuat postingan (berita, pengumuman, dokumentasi).
💬 Fitur Chat: Berkomunikasi individu atau grup (fungsionalitas terbatas - lihat bagian Status Proyek).
📖 Renungan Harian: Ayat renungan dan "Fun Fact" liturgi.

Untuk Admin:
⚙️ Dasbor Admin: Ringkasan dan navigasi ke alat manajemen.
📅 Manajemen Jadwal: Tambah, Edit, Hapus jadwal misa.
📖 Manajemen Materi: Unggah, Edit, Hapus materi pembelajaran.
📢 Manajemen Notifikasi: Membuat & Mengirim notifikasi (terbatas - lihat bagian Status Proyek).
✍️ Manajemen Postingan: Tambah, Edit, Hapus postingan.
👥 Manajemen Pengguna: Melihat daftar dan detail pengguna.
📊 Laporan Kehadiran: Melihat laporan kehadiran Misdinar (terbatas - lihat bagian Status Proyek).

🛠️ Teknologi Digunakan
Frontend:
Flutter: SDK UI dari Google untuk membangun aplikasi native dari satu codebase.
Dart: Bahasa pemrograman Flutter.
Provider: Solusi manajemen state untuk Flutter.

Backend:
Firebase: Platform pengembangan aplikasi mobile dari Google.
Firebase Authentication: Sistem otentikasi pengguna.
Cloud Firestore: Basis data NoSQL real-time.
Firebase Storage: Penyimpanan file (gambar, PDF).
Firebase Cloud Messaging (FCM): Layanan notifikasi push.
Firebase Cloud Functions: Lingkungan eksekusi kode serverless (penggunaan terbatas).

🚧 Status Proyek & Kendala
AltarLink telah berhasil mengimplementasikan sebagian besar fungsionalitas sisi klien dan interaksi dasar dengan Firebase Authentication, Firestore, dan Storage.
Kendala Signifikan:
Proyek menghadapi hambatan besar terkait verifikasi pembayaran Visa pada akun Firebase. Kendala ini secara langsung membatasi deployment penuh dan pengujian fungsionalitas yang sangat bergantung pada layanan Firebase berbayar, seperti:
- Validasi QR Code kehadiran server-side yang robust (membutuhkan Cloud Functions).
- Notifikasi otomatis skala besar (membutuhkan Cloud Functions dan penggunaan FCM berbayar).
- Fitur chat real-time yang kompleks (terkadang bergantung pada server-side logic tambahan).
Sebagai hasilnya, scope fungsionalitas backend yang tercapai menjadi parsial. Tim beradaptasi dengan fokus pada deliverable yang dapat diimplementasikan sepenuhnya dalam batas layanan Firebase gratis.

🚀 Cara Instalasi & Menjalankan
Persyaratan Sistem
- Perangkat Android: Android 7.0 (Nougat) atau lebih baru.
- Ruang Penyimpanan: Minimum 100MB tersedia.
- Koneksi Internet: Diperlukan untuk fungsionalitas backend.

Untuk Pengguna (Instalasi APK)
- Unduh file APK (.apk) AltarLink dari sumber terpercaya yang dibagikan (misalnya, tautan Google Drive).
- Aktifkan "Instal aplikasi tidak dikenal" di pengaturan keamanan perangkat Android Anda (Pengaturan > Keamanan/Privasi).
- Buka file .apk yang sudah diunduh dan ikuti instruksi instalasi.
- Jalankan aplikasi dari ikon di layar utama Anda.

📖 Penggunaan Aplikasi
Panduan pengguna terperinci tersedia dalam Dokumen Panduan Pengguna AltarLink.

🤝 Kontribusi
Saat ini, proyek ini merupakan hasil dari Capstone Project individu dan tidak menerima kontribusi eksternal. Namun, ide dan feedback konstruktif selalu dihargai!

📧 Kontak
Untuk pertanyaan lebih lanjut atau kolaborasi, jangan ragu untuk menghubungi:
Email: aldian.535230139@stu.untar.ac.id
GitHub: @AldianYohanes 
