import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const DQuotesApp());
}

class DQuotesApp extends StatelessWidget {
  const DQuotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DQuotes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'sans-serif',
      ),
      home: const HomeScreen(),
    );
  }
}
