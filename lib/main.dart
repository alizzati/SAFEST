// (File: main.dart)

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'config/routes.dart'; // Asumsi file ini berisi fungsi createRouter()
// ... (imports lainnya)

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Ambil router configuration
    final GoRouter router =
        createRouter(); // Asumsi fungsi ini didefinisikan di config/routes.dart

    return MaterialApp.router(
      title: 'Safest',
      theme: ThemeData(
        fontFamily: 'OpenSans',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF512DA8)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,

      // 2. HAPUS properti 'initialRoute' dan 'routes' yang lama
      // 3. Masukkan routerConfig ke MaterialApp.router
      routerConfig: router,
    );
  }
}
