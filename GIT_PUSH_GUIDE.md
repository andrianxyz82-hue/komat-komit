# 📤 Panduan Push Update ke GitHub

## 🔍 Cek Status Git

Pertama, cek status perubahan:

```bash
cd d:/nasi-padang-main
git status
```

## 📝 Tambahkan Semua Perubahan

Tambahkan semua file yang berubah:

```bash
git add .
```

Atau tambahkan file spesifik:

```bash
git add lib/features/student/edit_profile_screen.dart
git add lib/features/student/profile_screen.dart
git add lib/features/about/about_screen.dart
git add lib/features/teacher/bulk_import_questions_screen.dart
git add lib/features/teacher/add_questions_screen.dart
git add android/app/src/main/AndroidManifest.xml
git add android/app/src/main/kotlin/com/eskalasi/safeexam/safe_exam_app/MainActivity.kt
git add lib/features/exam/exam_detail_screen.dart
git add lib/services/lock_service.dart
git add pubspec.yaml
```

## 💬 Commit Perubahan

Buat commit dengan pesan yang jelas:

```bash
git commit -m "feat: Add profile edit, about page, bulk import & fix lock screen

- Add edit profile feature (name, class, daily quote)
- Add about page with developer info
- Add bulk question import (text-based)
- Fix lock screen permission loop
- Add anti-floating apps features
- Update monitoring to show student names
- Remove back button from student home screen"
```

## 🚀 Push ke GitHub

Push ke repository:

```bash
git push origin main
```

Atau jika branch kamu berbeda (misal `master`):

```bash
git push origin master
```

## ⚠️ Jika Ada Conflict

Jika ada conflict, pull dulu:

```bash
git pull origin main
```

Lalu resolve conflict, kemudian:

```bash
git add .
git commit -m "Merge remote changes"
git push origin main
```

## 🔐 Jika Perlu Login

Jika diminta login, gunakan:
- **Username**: GitHub username kamu
- **Password**: Personal Access Token (bukan password biasa)

### Cara Buat Personal Access Token:
1. GitHub → Settings → Developer settings
2. Personal access tokens → Tokens (classic)
3. Generate new token
4. Pilih scope: `repo` (full control)
5. Copy token dan gunakan sebagai password

## ✅ Verifikasi

Cek di GitHub repository kamu apakah perubahan sudah masuk:
```
https://github.com/YOUR_USERNAME/YOUR_REPO_NAME
```

## 📊 Summary Perubahan

**Files Modified**:
- ✅ `edit_profile_screen.dart` (NEW)
- ✅ `about_screen.dart` (NEW)
- ✅ `bulk_import_questions_screen.dart` (NEW)
- ✅ `profile_screen.dart`
- ✅ `add_questions_screen.dart`
- ✅ `student_home_screen.dart`
- ✅ `exam_detail_screen.dart`
- ✅ `lock_service.dart`
- ✅ `MainActivity.kt`
- ✅ `AndroidManifest.xml`
- ✅ `pubspec.yaml`

**Features Added**:
- ✅ Edit Profile (nama, kelas, kata-kata)
- ✅ About Page (developer info)
- ✅ Bulk Import Soal (text-based)
- ✅ Lock Screen Fixes (permission loop, anti-floating)
- ✅ Submit button logic (enabled near end)
- ✅ Monitoring shows student names

---

**Database Migration Required**:
```sql
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS full_name TEXT,
ADD COLUMN IF NOT EXISTS class TEXT,
ADD COLUMN IF NOT EXISTS daily_quote TEXT;
```

Jangan lupa update database di Supabase sebelum deploy! 🎯
