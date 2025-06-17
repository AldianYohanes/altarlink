AltarLink: Aplikasi Mobile Manajemen Aktivitas Liturgi Misdinar
AltarLink adalah sebuah aplikasi mobile berbasis Flutter yang dirancang untuk mempermudah manajemen aktivitas liturgi dan memperkuat komunikasi di antara Misdinar Gereja Katolik Maria Bunda Karmel, Paroki Tomang. Aplikasi ini bertujuan menciptakan ekosistem digital yang terintegrasi dan kolaboratif untuk pelayanan liturgi yang lebih efisien dan berkualitas.

Daftar Isi
Latar Belakang

Deskripsi Proyek

Fitur Utama

Teknologi Digunakan

Arsitektur Sistem

Status Proyek & Kendala

Cara Instalasi & Menjalankan

Penggunaan Aplikasi

Kontribusi

Lisensi

Kontak

1. Latar Belakang
Manajemen jadwal tugas yang padat, keterbatasan akses terhadap materi edukatif yang terstandarisasi, serta potensi disorganisasi dalam pelayanan liturgi seringkali menjadi tantangan bagi para Misdinar. AltarLink hadir sebagai respons digital untuk mengatasi permasalahan tersebut, menyediakan platform terpusat untuk informasi, panduan, dan komunikasi yang mudah diakses, sejalan dengan tren adopsi teknologi dalam komunitas keagamaan.

2. Deskripsi Proyek
AltarLink adalah aplikasi mobile yang berfungsi sebagai pusat informasi dan alat bantu bagi Misdinar dan Pengurus Gereja. Aplikasi ini didesain untuk:

Mengatasi kesulitan dalam mengingat jadwal pelayanan.

Menyediakan akses mudah terhadap materi edukatif terstandarisasi.

Mengurangi disorganisasi dalam tata cara pelayanan.

Menyediakan notifikasi pengingat tugas.

Memperkaya spiritualitas melalui ayat renungan harian.

Memfasilitasi interaksi dan berbagi pengalaman antar Misdinar melalui fitur postingan dan chat.

3. Fitur Utama
Aplikasi AltarLink menyediakan fungsionalitas inti berikut:

Manajemen Akun Pengguna:

Registrasi & Login Akun

Melihat & Memperbarui Profil

Reset Kata Sandi

Manajemen Jadwal Liturgi & Kehadiran:

Melihat Kalender Liturgi Harian

Melihat Jadwal Pelayanan Misa

Konfirmasi Kehadiran Misa (Fitur Scan QR - lihat bagian Status Proyek & Kendala)

Melihat Riwayat Kehadiran Pribadi

Manajemen Konten Edukatif & Informasi:

Mengakses Materi Pembelajaran (PDF, Gambar)

Melihat Ayat Renungan Harian & Fun Fact Liturgi

Melihat & Membuat Postingan Komunitas

Melihat Notifikasi dari Admin

Fitur Komunikasi & Interaksi:

Mengakses Fitur Chat (Individual & Grup - lihat bagian Status Proyek & Kendala)

Fungsi Administratif (untuk Admin):

Mengelola Jadwal Misa (CRUD)

Mengelola Materi Pembelajaran (CRUD)

Mengelola Postingan (CRUD)

Mengelola Notifikasi (Membuat & Mengirim - lihat bagian Status Proyek & Kendala)

Mengelola Pengguna

Melihat Laporan Kehadiran Misa (terbatas, lihat bagian Status Proyek & Kendala)

4. Teknologi Digunakan
Frontend:

Flutter (Dart): Framework UI open-source untuk membangun aplikasi mobile multi-platform dari satu codebase tunggal, dengan performa mendekati native.

State Management: Provider.

Backend:

Firebase: Platform Backend-as-a-Service (BaaS) dari Google.

Firebase Authentication: Untuk manajemen otentikasi pengguna.

Cloud Firestore: Basis data NoSQL berbasis dokumen untuk penyimpanan data real-time.

Firebase Storage: Untuk penyimpanan berkas (misalnya PDF materi, gambar postingan).

Firebase Cloud Messaging (FCM): Untuk pengiriman notifikasi push.

Firebase Cloud Functions: Untuk logika backend serverless (penggunaan terbatas akibat kendala).

5. Arsitektur Sistem
AltarLink mengadopsi arsitektur client-server berbasis cloud. Aplikasi mobile Flutter bertindak sebagai client yang berinteraksi dengan berbagai layanan backend Firebase.

!(https://placehold.co/600x300/cccccc/333333?text=Arsitektur+AltarLink)

Lapisan Presentasi: Aplikasi Mobile AltarLink (UI/UX).

Lapisan Logika Aplikasi: Distribusi antara logika klien di Flutter dan Firebase Cloud Functions (untuk logika server-side yang kompleks).

Lapisan Data: Cloud Firestore (basis data) dan Firebase Storage (penyimpanan berkas).

6. Status Proyek & Kendala
Proyek AltarLink telah berhasil mengimplementasikan sebagian besar fungsionalitas sisi klien dan interaksi dasar dengan Firebase Firestore, Authentication, dan Storage.

Namun, proyek tidak dapat mencapai target fungsionalitas penuh, khususnya pada fitur yang sangat bergantung pada layanan Firebase yang memerlukan billing aktif, seperti:

Validasi QR Code kehadiran server-side yang robust: Meskipun pemindaian QR di sisi klien berfungsi, proses validasi dan pencatatan kehadiran yang aman di backend belum dapat diaktifkan sepenuhnya.

Notifikasi otomatis skala besar dan fitur chat real-time lanjutan: Implementasi penuh fitur-fitur ini sangat bergantung pada Firebase Cloud Functions dan penggunaan FCM yang melampaui kuota gratis.

Kendala ini muncul dikarenakan masalah verifikasi pembayaran Visa pada akun Firebase. Tim telah beradaptasi dengan kendala ini dengan memprioritaskan fitur-fitur yang dapat diimplementasikan dan diuji dalam batas layanan Firebase gratis.

7. Cara Instalasi & Menjalankan
Persyaratan Sistem
Android Device: Android 7.0 (Nougat) atau lebih baru.

Ruang Penyimpanan: Minimal 100MB tersedia.

Koneksi Internet: Diperlukan untuk mengakses fitur backend.

Untuk Pengguna (Instalasi APK)
Unduh APK: Dapatkan file APK AltarLink (.apk) dari sumber yang dibagikan oleh pengurus Gereja (misalnya, melalui tautan Google Drive).

Izinkan Instalasi dari Sumber Tidak Dikenal: Pada perangkat Android Anda, buka Pengaturan > Keamanan/Privasi (nama dapat bervariasi) dan aktifkan opsi Instal aplikasi tidak dikenal atau Sumber Tidak Dikenal.

Instal Aplikasi: Buka file .apk yang sudah diunduh dan ikuti petunjuk instalasi.

Jalankan: Ikon AltarLink akan muncul di layar utama perangkat Anda.

Untuk Pengembang (Menjalankan dari Source Code)
Klon Repositori:

git clone https://github.com/aldianYHS/altarlink.git
cd altarlink

Instal Dependensi Flutter:

flutter pub get

Konfigurasi Firebase:

Buat Proyek Firebase baru di Firebase Console.

Tambahkan aplikasi Android ke proyek Firebase Anda dan ikuti instruksi untuk menambahkan google-services.json ke direktori android/app/.

Aktifkan Firebase Authentication (Email/Password), Firestore Database, dan Firebase Storage di konsol Firebase Anda.

Catatan: Untuk menguji fitur yang terkendala (misalnya Cloud Functions), Anda perlu mengaktifkan billing di proyek Firebase Anda.

Jalankan Aplikasi:

flutter run

8. Penggunaan Aplikasi
Panduan lengkap penggunaan aplikasi tersedia dalam Dokumen Panduan Pengguna AltarLink. Secara singkat:

Misdinar: Dapat melihat jadwal misa, mengakses materi, melihat dan membuat postingan, melihat notifikasi, dan menggunakan fitur chat dasar.

Admin: Memiliki akses ke Dasbor Admin untuk mengelola data misa, materi, postingan, notifikasi, dan melihat laporan kehadiran.

9. Kontribusi
Mengingat ini adalah proyek Capstone pribadi, saat ini tidak ada kontribusi eksternal yang diterima. Namun, saran dan feedback selalu diterima melalui bagian Kontak.

10. Lisensi
Proyek ini dilisensikan di bawah lisensi MIT. Lihat file LICENSE untuk detail lebih lanjut.

11. Kontak
Untuk pertanyaan, saran, atau pelaporan isu, silakan hubungi:

Aldian Yohanes

Email: aldian.yohanes@example.com (ganti dengan email kontak yang relevan)

GitHub: aldianYHS (link ke profil GitHub Anda)
