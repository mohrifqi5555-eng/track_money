# Blueprint / Rencana Kerja Pengembangan "MoneyTrack"
Fase 1: Persiapan & Setup Proyek
Inisialisasi Proyek: Buat project Flutter baru (flutter create moneytrack).

Dependensi: Tambahkan package yang dibutuhkan di pubspec.yaml:

intl: Untuk format mata uang Rupiah (Rp).

shared_preferences atau hive / sqflite: Untuk penyimpanan data lokal (sesuai janji fitur "Aman, data tersimpan di lokal device"). Pada kode di bawah, kita gunakan data sementara di memori agar bisa langsung dirunning.

Fase 2: Pembuatan Struktur Data (Model)
Buat class TransactionItem yang berisi: id, judul (nama transaksi), nominal, jenis (Pemasukan/Pengeluaran), dan tanggal.

Fase 3: Pembuatan UI & Navigasi (View)
Tema Utama: Set warna utama aplikasi ke hijau (contoh: Colors.green[700]).

Screen 1 (Dashboard): Buat kartu Total Saldo, Pemasukan, Pengeluaran, dan daftar transaksi terbaru.

Screen 2 (Tambah Transaksi): Buat form input teks (nama), angka (nominal), tombol toggle (jenis), dan pemilih tanggal.

Screen 3 & 4 (Riwayat & Hapus): Buat ListView dengan widget Dismissible agar item bisa digeser ke kiri (swipe) untuk dihapus. Tambahkan filter tab (Semua, Pemasukan, Pengeluaran).

Bottom Navigation: Buat navigasi bawah untuk berpindah antar halaman.

Fase 4: Logika Bisnis & State Management (Controller)
Buat fungsi untuk menghitung total saldo otomatis (Total Pemasukan - Total Pengeluaran).

Buat fungsi tambahTransaksi() dan hapusTransaksi().
