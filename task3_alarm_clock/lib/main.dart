import 'package:flutter/material.dart';
import 'alarm_service.dart';
import 'home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final alarmService = AlarmService();

  runApp(AlarmClockApp(alarmService: alarmService));
}

class AlarmClockApp extends StatelessWidget {
  final AlarmService alarmService;

  const AlarmClockApp({
    super.key,
    required this.alarmService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neon Alarm Clock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7C3AED), // Indigo accent
          secondary: Color(0xFFF59E0B), // Glowing Amber
          surface: Color(0xFF1E293B),
          background: Color(0xFF0F172A),
        ),
        useMaterial3: true,
        fontFamily: 'sans-serif',
      ),
      home: HomeScreen(alarmService: alarmService),
    );
  }
}
