import 'package:flutter/material.dart';
import 'alarm.dart';
import 'alarm_service.dart';
import 'alarm_sound_helper.dart';

class AlarmRingScreen extends StatefulWidget {
  final Alarm alarm;
  final AlarmService alarmService;

  const AlarmRingScreen({
    super.key,
    required this.alarm,
    required this.alarmService,
  });

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // Play synthesized alarm sound immediately on start
    AlarmSoundHelper.play(widget.alarm.toneName);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _dismiss() {
    AlarmSoundHelper.stop();
    widget.alarmService.dismissAlarm();
    Navigator.of(context).pop();
  }

  void _snooze() {
    AlarmSoundHelper.stop();
    widget.alarmService.snoozeAlarm();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)], // Deep slate to dark indigo
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Top label
              Column(
                children: [
                  const Icon(
                    Icons.alarm_on_rounded,
                    color: Color(0xFFF59E0B),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.alarm.label.isNotEmpty ? widget.alarm.label : 'Wake Up!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tone: ${widget.alarm.toneName}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              // Ringing clock center with pulsating circular animations
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ring 1
                      Container(
                        width: 220 + (_pulseCtrl.value * 40),
                        height: 220 + (_pulseCtrl.value * 40),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED).withOpacity(0.12 * (1.0 - _pulseCtrl.value)),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Ring 2
                      Container(
                        width: 180 + (_pulseCtrl.value * 25),
                        height: 180 + (_pulseCtrl.value * 25),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.15 * (1.0 - _pulseCtrl.value)),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Center clock plate
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF7C3AED), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C3AED).withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          widget.alarm.formattedTime.split(' ')[0], // Time numbers
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    // Dismiss Button (glowing orange)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _dismiss,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444), // Crimson Red
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: const Color(0xFFEF4444).withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Dismiss Alarm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Snooze Button (dark/glass style)
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: _snooze,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Snooze (${widget.alarm.snoozeMinutes} mins)',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
