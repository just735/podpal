import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'views/start_page.dart';
import 'views/main_screen.dart';

void main() {
  runApp(const PodPalApp());
}

class PodPalApp extends StatelessWidget {
  const PodPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PodPal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B9D),
          primary: const Color(0xFFFF6B9D),
          secondary: const Color(0xFFC084FC),
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.notoSansTextTheme(),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      // 初始进入开始页
      initialRoute: '/',
      routes: {
        '/': (context) => const StartPage(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}
