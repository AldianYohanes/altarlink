# AltarLink: Aplikasi Mobile Manajemen Liturgi Misdinar 📱✨

**AltarLink** adalah aplikasi mobile inovatif yang dirancang untuk merevolusi manajemen aktivitas liturgi bagi Misdinar Gereja Katolik Maria Bunda Karmel, Paroki Tomang.  
Proyek ini bertujuan menciptakan ekosistem digital yang terintegrasi demi efisiensi operasional dan penguatan komunitas.

📥 **[Download APK](https://drive.google.com/drive/u/0/folders/1MvFnb-0PeLqdloHhjhY1uUoLTIeBvd-Z)**

---

## 🌟 Latar Belakang

Manajemen jadwal tugas yang padat, akses terbatas ke materi edukatif, dan potensi disorganisasi sering menjadi tantangan bagi para Misdinar.  
**AltarLink** hadir sebagai solusi digital yang menyediakan platform terpusat dan mudah diakses untuk informasi, panduan, dan komunikasi — guna mendukung pelayanan liturgi yang lebih terorganisir dan berkualitas.

---

## ✨ Fitur Utama

### Untuk Misdinar (Pengguna)
- 🔑 **Manajemen Akun:** Registrasi, Login, Profil & Reset Kata Sandi.  
- 🗓️ **Jadwal Misa:** Melihat jadwal pelayanan misa yang akan datang.  
- ✅ **Konfirmasi Kehadiran (QR Scan):** Fungsionalitas parsial (lihat *Status Proyek*).  
- 📚 **Materi Pembelajaran:** Akses materi edukatif dan informasi liturgi.  
- 🔔 **Notifikasi:** Menerima pengumuman penting dari Admin.  
- 📰 **Postingan Komunitas:** Melihat dan membuat postingan (berita, pengumuman, dokumentasi).  
- 💬 **Fitur Chat:** Chat individu atau grup *(fungsionalitas terbatas)*.  
- 📖 **Renungan Harian:** Ayat renungan & fun fact liturgi.

### Untuk Admin
- ⚙️ **Dasbor Admin:** Navigasi manajemen dan ringkasan data.  
- 📅 **Manajemen Jadwal:** Tambah, edit, dan hapus jadwal misa.  
- 📖 **Manajemen Materi:** Unggah, edit, dan hapus materi pembelajaran.  
- 📢 **Manajemen Notifikasi:** Buat & kirim notifikasi *(terbatas)*.  
- ✍️ **Manajemen Postingan:** Tambah, edit, dan hapus postingan komunitas.  
- 👥 **Manajemen Pengguna:** Lihat daftar dan detail pengguna.  
- 📊 **Laporan Kehadiran:** Lihat laporan kehadiran Misdinar *(terbatas)*.

---

## 🛠️ Teknologi yang Digunakan

### Frontend
- **Flutter**: SDK UI dari Google untuk membangun aplikasi native dari satu codebase.  
- **Dart**: Bahasa pemrograman utama.  
- **Provider**: Solusi state management.

### Backend
- **Firebase**  
  - *Authentication*: Otentikasi pengguna.  
  - *Cloud Firestore*: Basis data NoSQL real-time.  
  - *Storage*: Penyimpanan file (gambar, PDF).  
  - *Cloud Messaging (FCM)*: Push Notification.  
  - *Cloud Functions*: Serverless backend logic *(penggunaan terbatas)*.

---

## 🚧 Status Proyek & Kendala

AltarLink telah berhasil mengimplementasikan sebagian besar fungsionalitas klien dan interaksi dasar dengan Firebase.

**Kendala utama:**  
Verifikasi pembayaran *Visa* pada akun Firebase terhambat, sehingga membatasi fungsionalitas berbasis layanan berbayar:

- Validasi QR Code kehadiran (butuh Cloud Functions).  
- Notifikasi otomatis massal (butuh FCM & Cloud Functions).  
- Fitur chat real-time yang kompleks.

➡️ Tim memfokuskan pengembangan pada fitur yang bisa direalisasikan sepenuhnya dengan versi *gratis* Firebase.

---

## 🚀 Cara Instalasi & Menjalankan

### 📱 Untuk Pengguna (Instalasi APK)

**Syarat sistem:**
- Android 7.0 (Nougat) atau lebih baru  
- Minimal 100MB ruang penyimpanan  
- Koneksi internet untuk backend

**Langkah instalasi:**
1. Unduh file `.apk` dari [tautan ini](https://drive.google.com/drive/u/0/folders/1MvFnb-0PeLqdloHhjhY1uUoLTIeBvd-Z).  
2. Aktifkan *Install unknown apps* di pengaturan Android (Pengaturan > Keamanan/Privasi).  
3. Jalankan file `.apk` dan ikuti instruksi instalasi.  
4. Buka aplikasi dari ikon di layar utama.

---

## 📖 Panduan Penggunaan

Panduan lengkap penggunaan aplikasi tersedia dalam dokumen **Panduan Pengguna AltarLink** (lihat di link Google Drive Download APK).

---

## 🤝 Kontribusi

Proyek ini merupakan hasil dari *Capstone Project* individu dan **saat ini tidak menerima kontribusi eksternal**.  
Namun, ide dan feedback konstruktif **sangat dihargai!**

---

## 📧 Kontak

Untuk pertanyaan lebih lanjut atau peluang kolaborasi:

- ✉️ Email: [aldian.535230139@stu.untar.ac.id](mailto:aldian.535230139@stu.untar.ac.id)  
- 💻 GitHub: [@AldianYohanes](https://github.com/AldianYohanes)
