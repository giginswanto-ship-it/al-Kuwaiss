-- ====================================================================
-- SISTEM MANAJEMEN BASIS DATA KBIH KUWAISS
-- File: data_lokal.sql
-- Format: Plain SQL (PostgreSQL 12+)
-- Tanggal Pembuatan: 2026-10-07
-- Lembaga: Kelompok Bimbingan Ibadah Haji (KBIH) KUWAISS
-- Pimpinan: Ust. Zuhdi Rofiqi, LC
-- Alamat: Jl. Raya Bekasi Timur Regensi Blok H1 No 10, Mustika Jaya, Kota Bekasi
-- ====================================================================
-- 
-- CARA MENJALANKAN DI SERVER LIVE:
-- ====================================================================
-- 1. Menggunakan file plain SQL (.sql) langsung (Paling Direkomendasikan):
--    psql -U username_live -d nama_db_live -f data_lokal.sql
--
--    Jika ke server remote dengan host dan port:
--    psql -h host_live -p 5432 -U username_live -d nama_db_live -f data_lokal.sql
--
--    Atau menggunakan URI Connection String:
--    psql "postgresql://username_live:password@host_live:5432/nama_db_live" -f data_lokal.sql
--
-- 2. Jika Anda mengonversinya ke format custom archive (.dump):
--    pg_dump -U username_lokal -d nama_db_lokal -Fc -f data_lokal.dump
--    pg_restore -U username_live -d nama_db_live -v --no-owner --no-privileges data_lokal.dump
-- ====================================================================

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

BEGIN;

-- ====================================================================
-- 1. TABEL: JAMAAH (DATA JAMAAH & ALUMNI 18 ANGKATAN)
-- ====================================================================
CREATE TABLE IF NOT EXISTS jamaah (
    id BIGINT PRIMARY KEY,
    nama VARCHAR(255) NOT NULL,
    angkatan VARCHAR(10) NOT NULL,
    tahun VARCHAR(10),
    kota VARCHAR(100),
    alamat TEXT,
    regu VARCHAR(100),
    wa VARCHAR(50),
    mahrom VARCHAR(255),
    status VARCHAR(100),
    avatar TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_jamaah_angkatan ON jamaah(angkatan);
CREATE INDEX IF NOT EXISTS idx_jamaah_nama ON jamaah(nama);
CREATE INDEX IF NOT EXISTS idx_jamaah_kota ON jamaah(kota);

-- ====================================================================
-- 2. TABEL: GALERI_FOTO (JEJAK MABRUR KENANGAN TANAH SUCI)
-- ====================================================================
CREATE TABLE IF NOT EXISTS galeri_foto (
    id BIGINT PRIMARY KEY,
    jamaah_nama VARCHAR(255),
    angkatan VARCHAR(50),
    kategori VARCHAR(50) NOT NULL,
    judul VARCHAR(255) NOT NULL,
    image_url TEXT NOT NULL,
    tanggal VARCHAR(100),
    ukuran VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_galeri_kategori ON galeri_foto(kategori);
CREATE INDEX IF NOT EXISTS idx_galeri_angkatan ON galeri_foto(angkatan);

-- ====================================================================
-- 3. TABEL: PENGUMUMAN (JADWAL UMRAH, BROSUR & FLYER DIGITAL)
-- ====================================================================
CREATE TABLE IF NOT EXISTS pengumuman (
    id BIGINT PRIMARY KEY,
    judul VARCHAR(255) NOT NULL,
    kategori VARCHAR(50) NOT NULL,
    tipe_dokumen VARCHAR(100),
    tanggal_kegiatan VARCHAR(100),
    lokasi VARCHAR(255),
    pembimbing VARCHAR(255) DEFAULT 'Ust. Zuhdi Rofiqi, LC',
    highlight VARCHAR(255),
    ringkasan TEXT,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_pengumuman_kategori ON pengumuman(kategori);

-- ====================================================================
-- 3B. TABEL: PENGUMUMAN_BIRO_CONFIG (RUNNING TEXT / SLIGHT BERJALAN)
-- ====================================================================
CREATE TABLE IF NOT EXISTS pengumuman_biro_config (
    id SERIAL PRIMARY KEY,
    badge VARCHAR(100) DEFAULT 'PENGUMUMAN BIRO',
    teks TEXT NOT NULL,
    is_running BOOLEAN DEFAULT TRUE,
    kecepatan VARCHAR(50) DEFAULT 'normal',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================================
-- 4. TABEL: PIMPINAN_CONFIG (FOTO & POSISI HERO BANNER)
-- ====================================================================
CREATE TABLE IF NOT EXISTS pimpinan_config (
    id SERIAL PRIMARY KEY,
    nama_pimpinan VARCHAR(255) NOT NULL DEFAULT 'Ust. Zuhdi Rofiqi, LC',
    foto_src TEXT DEFAULT 'ustadz_zuhdi.jpg',
    pos_x INT DEFAULT 50,
    pos_y INT DEFAULT 20,
    zoom INT DEFAULT 100,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================================
-- 5. TABEL: FORUM_POSTS (DISKUSI UKHUWAH LINTAS ANGKATAN)
-- ====================================================================
CREATE TABLE IF NOT EXISTS forum_posts (
    id BIGINT PRIMARY KEY,
    author VARCHAR(255) NOT NULL,
    avatar TEXT,
    badge VARCHAR(100),
    kategori VARCHAR(50),
    judul VARCHAR(255) NOT NULL,
    konten TEXT NOT NULL,
    waktu VARCHAR(100),
    likes INT DEFAULT 0,
    komentar_json JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_forum_kategori ON forum_posts(kategori);

-- ====================================================================
-- SEED DATA: PIMPINAN CONFIG
-- ====================================================================
INSERT INTO pimpinan_config (id, nama_pimpinan, foto_src, pos_x, pos_y, zoom)
VALUES (1, 'Ust. Zuhdi Rofiqi, LC', 'ustadz_zuhdi.jpg', 50, 20, 100)
ON CONFLICT (id) DO UPDATE SET
    nama_pimpinan = EXCLUDED.nama_pimpinan,
    foto_src = EXCLUDED.foto_src,
    pos_x = EXCLUDED.pos_x,
    pos_y = EXCLUDED.pos_y,
    zoom = EXCLUDED.zoom,
    updated_at = CURRENT_TIMESTAMP;

-- ====================================================================
-- SEED DATA: PENGUMUMAN BIRO RUNNING TEXT
-- ====================================================================
INSERT INTO pengumuman_biro_config (id, badge, teks, is_running, kecepatan)
VALUES (1, 'PENGUMUMAN BIRO', 'Reuni Akbar & Tabligh Alumni Angkatan 1 s/d 15 segera dilaksanakan. Verifikasi kehadiran di menu Agenda. ✦ Pendaftaran Umrah Musim 1448 H & Manasik Haji Akbar telah dibuka. Hubungi Sekretariat KBIH KUWAISS (08129032182).', TRUE, 'normal')
ON CONFLICT (id) DO UPDATE SET
    badge = EXCLUDED.badge,
    teks = EXCLUDED.teks,
    is_running = EXCLUDED.is_running,
    kecepatan = EXCLUDED.kecepatan,
    updated_at = CURRENT_TIMESTAMP;

-- ====================================================================
-- SEED DATA: JAMAAH (31 Baris Data)
-- ====================================================================
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (1801, 'Ahmad Fauzi', '18', '2026', 'Bandung', 'Jl. Riau No. 45, Citarum, Kec. Bandung Wetan', 'Maktab 65 / Regu 01', '081311223344', 'Hj. Siti Marwah (Istri)', 'Jamaah Angkatan 18 (2026)', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (1802, 'Hj. Siti Marwah', '18', '2026', 'Jakarta Selatan', 'Jl. Fatmawati No. 18, Cilandak Barat', 'Maktab 65 / Regu 02', '081288990011', 'Ahmad Fauzi (Suami)', 'Jamaah Angkatan 18 (2026)', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (1803, 'H. Muhammad Arifin', '18', '2026', 'Kota Bekasi', 'Perumahan Grand Galaxy City Blok EB No. 14, Jaka Setia', 'Maktab 65 / Regu 03', '081290334455', '', 'Jamaah Angkatan 18 (2026)', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (1701, 'Hj. Nurhayati Idris', '17', '2025', 'Makassar', 'Jl. Pengayoman No. 12, Panakkukang', 'Maktab 62 / Regu 03', '081523456789', 'H. Syarifuddin Daeng (Suami)', 'Alumni 2025 (1446 H)', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (1702, 'H. Syarifuddin Daeng', '17', '2025', 'Gowa', 'Jl. Sultan Hasanuddin No. 88, Somba Opu', 'Maktab 62 / Regu 01', '081344557788', 'Hj. Nurhayati Idris (Istri)', 'Alumni 2025 (1446 H)', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (1601, 'H. Kusuma Wardana', '16', '2023', 'Jakarta Timur', 'Jl. Pemuda No. 88, Rawamangun', 'Maktab 58 / Regu 02', '081377881122', NULL, 'Alumni 2023 (1445 H)', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (1602, 'Hj. Dewi Sartika Lubis', '16', '2023', 'Kota Bekasi', 'Jl. Kemang Pratama Raya Blok AL No. 5, Rawalumbu', 'Maktab 58 / Regu 04', '081299887711', NULL, 'Alumni 2023 (1445 H)', 'https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (1501, 'H. Ridwan Kamiludin', '15', '2022', 'Bandung', 'Jl. Dago No. 102, Coblong', 'Maktab 50 / Regu 01', '081765432100', NULL, 'Alumni 2022 (1444 H)', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (1502, 'Hj. Anisa Rahmawati', '15', '2022', 'Cimahi', 'Jl. Gatot Subroto No. 34, Cimahi Tengah', 'Maktab 50 / Regu 03', '081399881122', NULL, 'Alumni 2022 (1444 H)', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (1401, 'Hj. Ratna Dewanti', '14', '2021', 'Semarang', 'Jl. Pandanaran No. 56, Mugassari', 'Maktab 48 / Regu 04', '081233445566', NULL, 'Alumni 2021 (1443 H)', 'https://images.unsplash.com/photo-1548142813-c348350df52b?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (1301, 'H. Firman Utina', '13', '2019', 'Tangerang', 'Komp. BSD City Sektor 1.2, Serpong', 'Maktab 46 / Regu 03', '081344556677', NULL, 'Alumni 2019 (1441 H)', 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (1302, 'Hj. Farida Hanum', '13', '2019', 'Tangerang Selatan', 'Bintaro Jaya Sektor 7 Blok B No. 12', 'Maktab 46 / Regu 02', '081288776655', NULL, 'Alumni 2019 (1441 H)', 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (1201, 'Hj. Kartini Malik', '12', '2018', 'Surabaya', 'Jl. Darmo No. 74, Wonokromo', 'Maktab 44 / Regu 01', '081255667788', NULL, 'Alumni 2018 (1440 H)', 'https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (1202, 'H. Subagyo Broto', '12', '2018', 'Sidoarjo', 'Perum Puri Surya Jaya Blok H3 No. 9, Gedangan', 'Maktab 44 / Regu 03', '081133224455', NULL, 'Alumni 2018 (1440 H)', 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (1101, 'H. Lukman Hakim', '11', '2017', 'Bogor', 'Jl. Pajajaran No. 27, Baranangsiang', 'Maktab 42 / Regu 05', '081366778899', NULL, 'Alumni 2017 (1439 H)', 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (1102, 'Hj. Yuliana Syahrir', '11', '2017', 'Depok', 'Jl. Margonda Raya No. 120, Beji', 'Maktab 42 / Regu 02', '081299334411', NULL, 'Alumni 2017 (1439 H)', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (1001, 'Hj. Endang Sulastri', '10', '2016', 'Yogyakarta', 'Jl. Kaliurang Km 5.5, Depok, Sleman', 'Maktab 45 / Regu 05', '081299112233', NULL, 'Alumni 2016 (1438 H)', 'https://images.unsplash.com/photo-1548142813-c348350df52b?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (1002, 'H. Danang Wicaksono', '10', '2016', 'Bantul', 'Jl. Bantul Km 7, Sewon', 'Maktab 45 / Regu 01', '08112998877', NULL, 'Alumni 2016 (1438 H)', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (901, 'H. Gunawan Wibisono', '9', '2015', 'Malang', 'Jl. Ijen No. 19, Klojen', 'Maktab 36 / Regu 02', '081277881100', NULL, 'Alumni 2015 (1437 H)', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (801, 'Hj. Mardiah Hasibuan', '8', '2014', 'Medan', 'Jl. Setia Budi No. 110, Medan Sunggal', 'Maktab 32 / Regu 03', '081388992211', NULL, 'Alumni 2014 (1436 H)', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (701, 'H. Zulkifli Harahap', '7', '2013', 'Padang', 'Jl. Khatib Sulaiman No. 34, Padang Barat', 'Maktab 28 / Regu 01', '081299003322', NULL, 'Alumni 2013 (1435 H)', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (601, 'Hj. Rosmini Yusuf', '6', '2012', 'Palembang', 'Jl. Sudirman No. 89, Ilir Timur I', 'Maktab 25 / Regu 04', '081311004433', NULL, 'Alumni 2012 (1434 H)', 'https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (501, 'H. Dedi Haryanto', '5', '2011', 'Bandung', 'Jl. Buah Batu No. 142, Lengkong', 'Maktab 22 / Regu 02', '081399887766', NULL, 'Alumni 2011 (1433 H)', 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (401, 'Hj. Halimah Sadiah', '4', '2010', 'Solo', 'Jl. Slamet Riyadi No. 215, Laweyan', 'Maktab 18 / Regu 03', '081222115544', NULL, 'Alumni 2010 (1432 H)', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (301, 'H. Syamsul Arifin', '3', '2009', 'Jakarta Selatan', 'Jl. Fatmawati No. 45, Cilandak, Jakarta Selatan', 'Maktab 38 / Regu 04', '081234567890', NULL, 'Alumni Angkatan 3 (2009 / 1431 H)', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (302, 'Hj. Aminah Zahra', '3', '2009', 'Jakarta Selatan', 'Jl. Kemang Raya No. 10B, Mampang Prapatan', 'Maktab 38 / Regu 04', '081234567891', NULL, 'Alumni Angkatan 3 (2009 / 1431 H)', 'https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (201, 'H. Abdullah Dahlan', '2', '2008', 'Cirebon', 'Jl. Siliwangi No. 63, Kejaksan', 'Maktab 15 / Regu 02', '081133446677', NULL, 'Alumni Angkatan 2 (2008 / 1430 H)', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (202, 'Hj. Masitoh Hasan', '2', '2008', 'Kuningan', 'Jl. Veteran No. 40, Purwawinangun', 'Maktab 15 / Regu 01', '081244556688', NULL, 'Alumni Angkatan 2 (2008 / 1430 H)', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (101, 'H. Bambang Soediro', '1', '2007', 'Surabaya', 'Jl. Raya Gubeng No. 50, Gubeng', 'Maktab 12 / Regu 01', '081122334455', NULL, 'Senior Angkatan 1 (Musim Perdana 2007 / 1428 H)', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (102, 'H. Muchtar Luthfi', '1', '2007', 'Medan', 'Jl. Diponegoro No. 18, Medan Baru', 'Maktab 12 / Regu 02', '081277889900', NULL, 'Senior Angkatan 1 (Musim Perdana 2007 / 1428 H)', 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;
INSERT INTO jamaah (id, nama, angkatan, tahun, kota, alamat, regu, wa, mahrom, status, avatar)
VALUES (103, 'Hj. Siti Aisyah Rahman', '1', '2007', 'Kota Bekasi', 'Perumahan Kemang Pratama 2 Blok M No. 8, Rawalumbu', 'Maktab 12 / Regu 03', '081288001122', NULL, 'Senior Angkatan 1 (Musim Perdana 2007 / 1428 H)', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=120')
ON CONFLICT (id) DO UPDATE SET
    nama = EXCLUDED.nama, angkatan = EXCLUDED.angkatan, tahun = EXCLUDED.tahun, kota = EXCLUDED.kota,
    alamat = EXCLUDED.alamat, regu = EXCLUDED.regu, wa = EXCLUDED.wa, mahrom = EXCLUDED.mahrom, status = EXCLUDED.status, avatar = EXCLUDED.avatar;

-- ====================================================================
-- SEED DATA: GALERI FOTO (6 Baris Data)
-- ====================================================================
INSERT INTO galeri_foto (id, jamaah_nama, angkatan, kategori, judul, image_url, tanggal, ukuran)
VALUES (1, 'H. Syamsul Arifin', 'Angkatan 3', 'IHRAM', 'Niat Ihram di Miqat Bir Ali', 'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?auto=format&fit=crop&q=80&w=600', '1433 H / 2012 M', '382 KB (Terkompresi)')
ON CONFLICT (id) DO UPDATE SET
    jamaah_nama = EXCLUDED.jamaah_nama, angkatan = EXCLUDED.angkatan, kategori = EXCLUDED.kategori, judul = EXCLUDED.judul, image_url = EXCLUDED.image_url;
INSERT INTO galeri_foto (id, jamaah_nama, angkatan, kategori, judul, image_url, tanggal, ukuran)
VALUES (2, 'H. Syamsul Arifin', 'Angkatan 3', 'ARAFAH', 'Kekhusyukan Wukuf di Tenda Arafah', 'https://images.unsplash.com/photo-1564769625905-50e93615e769?auto=format&fit=crop&q=80&w=600', '1433 H / 2012 M', '410 KB (Terkompresi)')
ON CONFLICT (id) DO UPDATE SET
    jamaah_nama = EXCLUDED.jamaah_nama, angkatan = EXCLUDED.angkatan, kategori = EXCLUDED.kategori, judul = EXCLUDED.judul, image_url = EXCLUDED.image_url;
INSERT INTO galeri_foto (id, jamaah_nama, angkatan, kategori, judul, image_url, tanggal, ukuran)
VALUES (3, 'Hj. Aminah Zahra', 'Angkatan 3', 'MUZDALIFAH', 'Mabit di Bawah Langit Muzdalifah', 'https://images.unsplash.com/photo-1580418827493-f2b22c0a76cb?auto=format&fit=crop&q=80&w=600', '1433 H / 2012 M', '395 KB (Terkompresi)')
ON CONFLICT (id) DO UPDATE SET
    jamaah_nama = EXCLUDED.jamaah_nama, angkatan = EXCLUDED.angkatan, kategori = EXCLUDED.kategori, judul = EXCLUDED.judul, image_url = EXCLUDED.image_url;
INSERT INTO galeri_foto (id, jamaah_nama, angkatan, kategori, judul, image_url, tanggal, ukuran)
VALUES (4, 'H. Syamsul Arifin', 'Angkatan 3', 'THAWAF', 'Thawaf Ifadhah Menatap Ka''bah', 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=600', '1433 H / 2012 M', '420 KB (Terkompresi)')
ON CONFLICT (id) DO UPDATE SET
    jamaah_nama = EXCLUDED.jamaah_nama, angkatan = EXCLUDED.angkatan, kategori = EXCLUDED.kategori, judul = EXCLUDED.judul, image_url = EXCLUDED.image_url;
INSERT INTO galeri_foto (id, jamaah_nama, angkatan, kategori, judul, image_url, tanggal, ukuran)
VALUES (5, 'H. Bambang Soediro', 'Angkatan 1', 'ZIARAH', 'Ziarah Makam Rasulullah & Raudhah', 'https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?auto=format&fit=crop&q=80&w=600', '1431 H / 2010 M', '405 KB (Terkompresi)')
ON CONFLICT (id) DO UPDATE SET
    jamaah_nama = EXCLUDED.jamaah_nama, angkatan = EXCLUDED.angkatan, kategori = EXCLUDED.kategori, judul = EXCLUDED.judul, image_url = EXCLUDED.image_url;
INSERT INTO galeri_foto (id, jamaah_nama, angkatan, kategori, judul, image_url, tanggal, ukuran)
VALUES (6, 'Hj. Nurhayati Idris', 'Angkatan 15', 'THAWAF', 'Sa''i di Antara Shafa dan Marwah', 'https://images.unsplash.com/photo-1565552645632-d725f8bfc19a?auto=format&fit=crop&q=80&w=600', '1445 H / 2024 M', '390 KB (Terkompresi)')
ON CONFLICT (id) DO UPDATE SET
    jamaah_nama = EXCLUDED.jamaah_nama, angkatan = EXCLUDED.angkatan, kategori = EXCLUDED.kategori, judul = EXCLUDED.judul, image_url = EXCLUDED.image_url;

-- ====================================================================
-- SEED DATA: PENGUMUMAN & BROSUR (10 Baris Data)
-- ====================================================================
INSERT INTO pengumuman (id, judul, kategori, tipe_dokumen, tanggal_kegiatan, lokasi, pembimbing, highlight, ringkasan, image_url)
VALUES (1, 'Jadwal Keberangkatan Umrah Syawal & Awal Musim 1448 H (Paket 12 Hari)', 'JADWAL_UMRAH', 'Jadwal Umrah Terdekat', 'Keberangkatan: 28 Syawal 1447 H / 16 Mei 2026', 'Rute: Bandara Soekarno Hatta (CGK) – Madinah (MED) – Makkah (JED)', 'Bimbingan Penuh: Ust. Zuhdi Rofiqi, LC', 'Seat Tersisa 12 Jamaah (Kloter Terdekat)', 'Pemberitahuan resmi jadwal keberangkatan umrah terdekat kloter Syawal dan awal musim 1448 H. Fasilitas hotel bintang 5 ring 1 pelataran Masjidil Haram & Nabawi, ziarah napak tilas Badar & Uhud, serta manasik intensif 3 kali.', 'https://images.unsplash.com/photo-1564769625905-50e93615e769?auto=format&fit=crop&q=80&w=800')
ON CONFLICT (id) DO UPDATE SET
    judul = EXCLUDED.judul, kategori = EXCLUDED.kategori, tipe_dokumen = EXCLUDED.tipe_dokumen,
    tanggal_kegiatan = EXCLUDED.tanggal_kegiatan, lokasi = EXCLUDED.lokasi, ringkasan = EXCLUDED.ringkasan, image_url = EXCLUDED.image_url;
INSERT INTO pengumuman (id, judul, kategori, tipe_dokumen, tanggal_kegiatan, lokasi, pembimbing, highlight, ringkasan, image_url)
VALUES (2, 'Rencana Jadwal Umrah Liburan Akhir Tahun & Awal Tahun 1448 H', 'JADWAL_UMRAH', 'Jadwal Umrah Terdekat', 'Estimasi Keberangkatan: 22 Desember 2026 (12 Hari)', 'Makkah - Madinah (Penerbangan Saudia Airlines Direct)', 'Ust. Zuhdi Rofiqi, LC & Tim Pembimbing', 'Pendaftaran Early Bird Dibuka', 'Jadwal umrah keluarga menyambut liburan akhir tahun dengan paket kenyamanan ekstra ramah lansia dan anak, didampingi muthawwif berpengalaman dari KBIH KUWAISS.', 'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?auto=format&fit=crop&q=80&w=800')
ON CONFLICT (id) DO UPDATE SET
    judul = EXCLUDED.judul, kategori = EXCLUDED.kategori, tipe_dokumen = EXCLUDED.tipe_dokumen,
    tanggal_kegiatan = EXCLUDED.tanggal_kegiatan, lokasi = EXCLUDED.lokasi, ringkasan = EXCLUDED.ringkasan, image_url = EXCLUDED.image_url;
INSERT INTO pengumuman (id, judul, kategori, tipe_dokumen, tanggal_kegiatan, lokasi, pembimbing, highlight, ringkasan, image_url)
VALUES (3, 'Pendaftaran Calon Jamaah Haji Reguler, Haji Plus & Furoda 1448 H / 2027', 'PENDAFTARAN', 'Alur Pendaftaran Jamaah', 'Dibuka Setiap Hari Kerja (08.30 – 16.30 WIB)', 'Sekretariat KBIH KUWAISS: Jl. Raya Bekasi Timur Regensi Blok H1 No 10', 'Layanan Satu Atap Pendaftaran: 08129032182', 'Fasilitas Bimbingan Manasik Lengkap', 'KBIH KUWAISS membuka pendaftaran bimbingan haji reguler, pendaftaran porsi haji khusus (kuota resmi Kemenag), dan visa mujamalah/furoda langsung berangkat tanpa antri. Dapatkan pendampingan pembukaan tabungan haji hingga validasi SPPH.', 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&q=80&w=800')
ON CONFLICT (id) DO UPDATE SET
    judul = EXCLUDED.judul, kategori = EXCLUDED.kategori, tipe_dokumen = EXCLUDED.tipe_dokumen,
    tanggal_kegiatan = EXCLUDED.tanggal_kegiatan, lokasi = EXCLUDED.lokasi, ringkasan = EXCLUDED.ringkasan, image_url = EXCLUDED.image_url;
INSERT INTO pengumuman (id, judul, kategori, tipe_dokumen, tanggal_kegiatan, lokasi, pembimbing, highlight, ringkasan, image_url)
VALUES (4, 'Brosur & Skema Tabungan Pendaftaran Umrah Terencana KBIH KUWAISS', 'PENDAFTARAN', 'Panduan Pendaftaran', 'Konsultasi Setiap Saat via WhatsApp / Datang Langsung', 'Kantor Pelayanan Cimuning, Mustika Jaya, Kota Bekasi', 'Customer Care: Ust. Zuhdi Rofiqi, LC (08129032182)', 'DP Terjangkau & Pelunasan Bertahap', 'Bagi kaum muslimin yang merencanakan umrah bersama keluarga, tersedia program tabungan umrah fleksibel bekerjasama dengan bank syariah terpercaya dan pendampingan registrasi online.', 'https://images.unsplash.com/photo-1450133064473-71024230f91b?auto=format&fit=crop&q=80&w=800')
ON CONFLICT (id) DO UPDATE SET
    judul = EXCLUDED.judul, kategori = EXCLUDED.kategori, tipe_dokumen = EXCLUDED.tipe_dokumen,
    tanggal_kegiatan = EXCLUDED.tanggal_kegiatan, lokasi = EXCLUDED.lokasi, ringkasan = EXCLUDED.ringkasan, image_url = EXCLUDED.image_url;
INSERT INTO pengumuman (id, judul, kategori, tipe_dokumen, tanggal_kegiatan, lokasi, pembimbing, highlight, ringkasan, image_url)
VALUES (5, 'Pengajian Akbar, Dzikir Bersama & Silaturahmi Bulanan Alumni 18 Angkatan', 'PENGAJIAN', 'Jadwal Pertemuan Pengajian', 'Ahad, 19 April 2026 (Pukul 08.30 – 11.45 WIB)', 'Aula Utama KBIH KUWAISS / Masjid Al-Barkah Cimuning, Kota Bekasi', 'Penceramah: Ust. Zuhdi Rofiqi, LC', 'Waktu: Ahad Pagi | Tempat: Aula KBIH KUWAISS', 'Kajian rutin bulanan membahas fiqih kemabruran pasca haji, temu kangen seluruh alumni angkatan 1 (2007) s/d angkatan 18 (2026), serta santunan anak yatim binaan KBIHU.', 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=800')
ON CONFLICT (id) DO UPDATE SET
    judul = EXCLUDED.judul, kategori = EXCLUDED.kategori, tipe_dokumen = EXCLUDED.tipe_dokumen,
    tanggal_kegiatan = EXCLUDED.tanggal_kegiatan, lokasi = EXCLUDED.lokasi, ringkasan = EXCLUDED.ringkasan, image_url = EXCLUDED.image_url;
INSERT INTO pengumuman (id, judul, kategori, tipe_dokumen, tanggal_kegiatan, lokasi, pembimbing, highlight, ringkasan, image_url)
VALUES (6, 'Kajian Intensif Pra-Manasik: Menggapai Haji Mabrur Berlandaskan Sunnah', 'PENGAJIAN', 'Jadwal Pertemuan Pengajian', 'Sabtu, 25 April 2026 (Pukul 09.00 – 12.00 WIB)', 'Gedung Pertemuan KBIH KUWAISS Lantai 2, Mustika Jaya, Kota Bekasi', 'Ust. Zuhdi Rofiqi, LC', 'Khusus Calon Jamaah & Keluarga', 'Pendalaman tauhid, tazkiyatun nufus, adab musafir ke Tanah Suci, serta tanya jawab langsung seputar kendala praktis ibadah fisik bagi calon jamaah haji & umrah.', 'https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?auto=format&fit=crop&q=80&w=800')
ON CONFLICT (id) DO UPDATE SET
    judul = EXCLUDED.judul, kategori = EXCLUDED.kategori, tipe_dokumen = EXCLUDED.tipe_dokumen,
    tanggal_kegiatan = EXCLUDED.tanggal_kegiatan, lokasi = EXCLUDED.lokasi, ringkasan = EXCLUDED.ringkasan, image_url = EXCLUDED.image_url;
INSERT INTO pengumuman (id, judul, kategori, tipe_dokumen, tanggal_kegiatan, lokasi, pembimbing, highlight, ringkasan, image_url)
VALUES (7, 'Daftar Checklist Kelengkapan Dokumen Haji & Umrah Resmi 1447–1448 H', 'DOKUMEN', 'Panduan Dokumen Resmi', 'Batas Pengumpulan Berkas: Menyesuaikan Jadwal Kloter', 'Loket Pemberkasan KBIH KUWAISS Bekasi Timur', 'Staf Administrasi & Rekam Biometrik Bio Nusuk', 'Cek Kelengkapan Paspor & Biometrik', 'Kelengkapan berkas wajib: 1) Paspor asli berlaku min. 7 bulan (nama minimal 2 kata), 2) Salinan KTP, KK & Buku Nikah/Akta Lahir, 3) Pasfoto 4x6 latar putih (tampak wajah 80%), 4) Sertifikat Vaksin Meningitis & Polio, 5) Hasil rekam biometrik aplikasi Bio Visa/Nusuk.', 'https://images.unsplash.com/photo-1450133064473-71024230f91b?auto=format&fit=crop&q=80&w=800')
ON CONFLICT (id) DO UPDATE SET
    judul = EXCLUDED.judul, kategori = EXCLUDED.kategori, tipe_dokumen = EXCLUDED.tipe_dokumen,
    tanggal_kegiatan = EXCLUDED.tanggal_kegiatan, lokasi = EXCLUDED.lokasi, ringkasan = EXCLUDED.ringkasan, image_url = EXCLUDED.image_url;
INSERT INTO pengumuman (id, judul, kategori, tipe_dokumen, tanggal_kegiatan, lokasi, pembimbing, highlight, ringkasan, image_url)
VALUES (8, 'Panduan Pengurusan Paspor Baru, Penambahan Nama & Rekam Biometrik Visa', 'DOKUMEN', 'Petunjuk Teknis Dokumen', 'Layanan Pendampingan: Setiap Hari Selasa & Kamis', 'Kantor Imigrasi Terkait & Sekretariat KBIH KUWAISS', 'Tim Pendamping Administrasi KBIHU (08129032182)', 'Surat Rekomendasi Resmi Disediakan', 'KBIH KUWAISS menyediakan surat rekomendasi resmi Kemenag & bantuan asistensi pembuatan e-Paspor, penggantian paspor habis berlaku, serta pendampingan rekam sidik jari dan retina di smartphone.', 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&q=80&w=800')
ON CONFLICT (id) DO UPDATE SET
    judul = EXCLUDED.judul, kategori = EXCLUDED.kategori, tipe_dokumen = EXCLUDED.tipe_dokumen,
    tanggal_kegiatan = EXCLUDED.tanggal_kegiatan, lokasi = EXCLUDED.lokasi, ringkasan = EXCLUDED.ringkasan, image_url = EXCLUDED.image_url;
INSERT INTO pengumuman (id, judul, kategori, tipe_dokumen, tanggal_kegiatan, lokasi, pembimbing, highlight, ringkasan, image_url)
VALUES (9, 'Informasi Jadwal Manasik Haji Intensif Angkatan 18 (Musim 2026)', 'LAINNYA', 'Informasi Manasik & Kegiatan Lain', 'Mulai Sabtu, 10 Mei 2026 s/d Ahad, 18 Mei 2026', 'Pusat Simulasi Manasik Lapangan KBIH KUWAISS Bekasi Timur', 'Tim Pembimbing Ibadah KBIH KUWAISS', 'Brosur & Jadwal Manasik', 'Simulasi lengkap tata cara ihram miqat, thawaf, sa''i, wukuf miniatur Arafah, mabit Muzdalifah & Mina, hingga teknik lempar jumrah yang ramah lansia.', 'https://images.unsplash.com/photo-1580418827493-f2b22c0a76cb?auto=format&fit=crop&q=80&w=800')
ON CONFLICT (id) DO UPDATE SET
    judul = EXCLUDED.judul, kategori = EXCLUDED.kategori, tipe_dokumen = EXCLUDED.tipe_dokumen,
    tanggal_kegiatan = EXCLUDED.tanggal_kegiatan, lokasi = EXCLUDED.lokasi, ringkasan = EXCLUDED.ringkasan, image_url = EXCLUDED.image_url;
INSERT INTO pengumuman (id, judul, kategori, tipe_dokumen, tanggal_kegiatan, lokasi, pembimbing, highlight, ringkasan, image_url)
VALUES (10, 'Informasi Pengambilan Koper, Seragam Batik Haji & Perlengkapan Resmi', 'LAINNYA', 'Pengumuman Logistik', 'Pengambilan: Senin–Jumat (Pukul 09.00 – 16.00 WIB)', 'Gudang Logistik Sekretariat KBIH KUWAISS Cimuning', 'Bagian Logistik & Perlengkapan Jamaah', 'Tunjukkan Bukti Tanda Pendaftaran', 'Pengambilan paket perlengkapan resmi KBIH KUWAISS: Koper bagasi fiber 28 inch, tas kabin, tas paspor, kain ihram (pria) / mukena bergo (wanita), buku panduan doa saku, dan seragam batik resmi.', 'https://images.unsplash.com/photo-1565552645632-d725f8bfc19a?auto=format&fit=crop&q=80&w=800')
ON CONFLICT (id) DO UPDATE SET
    judul = EXCLUDED.judul, kategori = EXCLUDED.kategori, tipe_dokumen = EXCLUDED.tipe_dokumen,
    tanggal_kegiatan = EXCLUDED.tanggal_kegiatan, lokasi = EXCLUDED.lokasi, ringkasan = EXCLUDED.ringkasan, image_url = EXCLUDED.image_url;

-- ====================================================================
-- SEED DATA: FORUM DISKUSI (3 Baris Data)
-- ====================================================================
INSERT INTO forum_posts (id, author, avatar, badge, kategori, judul, konten, waktu, likes, komentar_json)
VALUES (101, 'Ahmad Fauzi', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=120', 'Angkatan 18 (2026)', 'LINTAS', 'Tanya Alumni: Perlengkapan apa yang paling penting dipersiapkan saat mabit di Mina?', 'Bismillah, assalamu alaikum para alumni senior. Mohon tipsnya, untuk persiapan fisik dan alas tidur saat mabit di Mina apakah tendanya cukup padat? Apa yang wajib kami bawa di ransel kecil?', '3 jam lalu', 12, '[{"author":"H. Syamsul Arifin","badge":"Alumni Angkatan 3 (2012)","text":"Wa alaikumussalam saudaraku. Bawalah sleeping mat portable yang tipis dan bantal tiup. Sandal jepit cadangan dan botol semprotan air untuk cuaca panas sangat membantu."},{"author":"Ust. Zuhdi Rofiqi, LC","badge":"Pembimbing Ibadah","text":"Yang paling utama adalah menjaga kesabaran hati dan banyak berzikir. Jangan lupa obat-obatan pribadi yang rutin dikonsumsi agar selalu dalam tas pinggang."}]'::jsonb)
ON CONFLICT (id) DO UPDATE SET
    author = EXCLUDED.author, avatar = EXCLUDED.avatar, badge = EXCLUDED.badge,
    kategori = EXCLUDED.kategori, judul = EXCLUDED.judul, konten = EXCLUDED.konten, likes = EXCLUDED.likes, komentar_json = EXCLUDED.komentar_json;
INSERT INTO forum_posts (id, author, avatar, badge, kategori, judul, konten, waktu, likes, komentar_json)
VALUES (102, 'H. Bambang Soediro', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=120', 'Alumni Angkatan 1 (2010)', 'REGIONAL', 'Rencana Temu Kangen & Halal Bi Halal Wilayah Jawa Timur', 'Salam ukhuwah untuk seluruh alumni KBIH KUWAISS di Surabaya, Malang, dan Sidoarjo. Insya Allah akhir bulan ini kita adakan sarapan bersama sambil membahas program wakaf bersama.', '1 hari lalu', 24, '[{"author":"Hj. Endang Sulastri","badge":"Alumni Angkatan 10","text":"Alhamdulillah, insya Allah saya dari Jogja siap ikut gabung jika diadakan di akhir pekan!"}]'::jsonb)
ON CONFLICT (id) DO UPDATE SET
    author = EXCLUDED.author, avatar = EXCLUDED.avatar, badge = EXCLUDED.badge,
    kategori = EXCLUDED.kategori, judul = EXCLUDED.judul, konten = EXCLUDED.konten, likes = EXCLUDED.likes, komentar_json = EXCLUDED.komentar_json;
INSERT INTO forum_posts (id, author, avatar, badge, kategori, judul, konten, waktu, likes, komentar_json)
VALUES (103, 'H. Syamsul Arifin', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=120', 'Alumni Angkatan 3 (2012)', 'INTRA', 'Temu Kangen Khusus Angkatan 3 (Maktab 38)', 'Sahabat seperjuangan 2012, tidak terasa sudah 14 tahun kita wukuf bersama di Arafah. Yuk kita kumpulkan kembali foto-foto di menu Galeri Jejak Mabrur untuk Yearbook angkatan kita.', '2 hari lalu', 18, '[{"author":"Hj. Aminah Zahra","badge":"Alumni Angkatan 3 (2012)","text":"Aamiin ya Rabbal alamin. Foto saat di Raudhah sudah saya unggah ya Pak Haji."}]'::jsonb)
ON CONFLICT (id) DO UPDATE SET
    author = EXCLUDED.author, avatar = EXCLUDED.avatar, badge = EXCLUDED.badge,
    kategori = EXCLUDED.kategori, judul = EXCLUDED.judul, konten = EXCLUDED.konten, likes = EXCLUDED.likes, komentar_json = EXCLUDED.komentar_json;

COMMIT;

-- Selesai! Data KBIH KUWAISS berhasil dimigrasikan ke PostgreSQL.
