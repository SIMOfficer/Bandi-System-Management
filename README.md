# Griyo Suite

Sistem quotation, invoice, tanda terima, dan keuangan terintegrasi untuk bisnis broker percetakan.
Menggantikan Griyo Pos, Canva (tanda terima/quotation), dan spreadsheet keuangan dengan satu sistem
yang saling terhubung.

## Setup Supabase (sekali di awal)

1. Buat akun & project baru di [supabase.com](https://supabase.com) (tier gratis cukup untuk mulai).
2. Buka **SQL Editor** di dashboard Supabase, tempel isi [`supabase/migrations/0001_init.sql`](supabase/migrations/0001_init.sql), lalu jalankan.
3. Buka **Authentication → Users**, buat 2 user (untuk Anda dan istri) dengan email + password.
4. Buka **Table Editor → business**, tambah 1 baris (nama bisnis, dll) — catat `id` yang ter-generate.
5. Buka **Table Editor → business_users**, tambah 2 baris menghubungkan `business_id` (dari langkah 4) ke masing-masing `user_id` (dari langkah 3, lihat di Authentication → Users).
6. Buka **Project Settings → API**, salin `Project URL` dan `anon public key`.
7. Salin `.env.local.example` menjadi `.env.local`, isi dengan nilai dari langkah 6.

## Menjalankan secara lokal

```bash
npm install
npm run dev
```

Buka [http://localhost:3000](http://localhost:3000) — akan diarahkan ke halaman login.

## Deploy ke Vercel

1. Push project ini ke GitHub.
2. Import repo di [vercel.com/new](https://vercel.com/new).
3. Tambahkan environment variables `NEXT_PUBLIC_SUPABASE_URL` dan `NEXT_PUBLIC_SUPABASE_ANON_KEY` di pengaturan project Vercel.
4. Deploy. Aplikasi bisa di-"Add to Home Screen" dari Chrome Android sebagai PWA.

## Struktur

- `supabase/migrations/0001_init.sql` — skema database & RLS.
- `src/lib/supabase/` — client Supabase untuk browser, server, dan proxy (auth guard).
- `src/app/(dashboard)/` — halaman setelah login (nav bersama di `layout.tsx`).
- `src/app/login/` — halaman login.
