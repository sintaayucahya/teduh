import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/profile_page.dart';

/// Entry point KHUSUS untuk mencoba halaman Profil secara terpisah.
/// Jalankan dengan:  flutter run -t lib/main_profile.dart
/// File ini tidak dipakai di aplikasi utama dan tidak menyentuh main.dart.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ProfilePage(),
  ));
}
