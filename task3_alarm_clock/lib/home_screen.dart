import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'alarm.dart';
import 'alarm_service.dart';
import 'alarm_ring_screen.dart';

class HomeScreen extends StatefulWidget {
  final AlarmService alarmService;

  const HomeScreen({
    super.key,
    required this.alarmService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });

    // Wire up trigger listener to navigate to Ring Screen
    widget.alarmService.onAlarmTriggered = (alarm) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AlarmRingScreen(
            alarm: alarm,
            alarmService: widget.alarmService,
          ),
        ),
      );
    };
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showAddAlarmSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B), // Deep slate dark sheet
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return AddAlarmSheet(alarmService: widget.alarmService);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm').format(_currentTime);
    final periodStr = DateFormat('a').format(_currentTime);
    final secondsStr = DateFormat(':ss').format(_currentTime);
    final dateStr = DateFormat('EEE, MMM d, yyyy').format(_currentTime);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Midnight slate
      body: AnimatedBuilder(
        animation: widget.alarmService,
        builder: (context, child) {
          final alarms = widget.alarmService.alarms;

          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                // ── HEADER ──
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Alarms',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Icon(
                        Icons.hourglass_empty_rounded,
                        color: Color(0xFF64748B),
                        size: 26,
                      ),
                    ],
                  ),
                ),

                // ── DIGITAL CLOCK DISPLAY ──
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Glow time box
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              timeStr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 68,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.0,
                              ),
                            ),
                            Text(
                              secondsStr,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              periodStr,
                              style: const TextStyle(
                                color: Color(0xFF7C3AED), // Indigo neon accent
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Date label
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            dateStr,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── ALARMS LIST HEADER ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'YOUR ALARMS',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        '${alarms.length} scheduled',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── ALARMS LIST ──
                Expanded(
                  flex: 5,
                  child: alarms.isEmpty
                      ? _emptyAlarmsState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: alarms.length,
                          itemBuilder: (context, index) {
                            final alarm = alarms[index];
                            return _alarmListItem(alarm);
                          },
                        ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 24, top: 10),
                  child: FloatingActionButton.extended(
                    onPressed: _showAddAlarmSheet,
                    backgroundColor: const Color(0xFF7C3AED), // Indigo accent
                    foregroundColor: Colors.white,
                    elevation: 6,
                    icon: const Icon(Icons.add_alarm_rounded, size: 22),
                    label: const Text(
                      'Set New Alarm',
                      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.2),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _emptyAlarmsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF64748B),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No alarms configured',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap below to set a wake-up time.',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _alarmListItem(Alarm alarm) {
    return Dismissible(
      key: Key(alarm.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        widget.alarmService.deleteAlarm(alarm.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${alarm.label.isNotEmpty ? alarm.label : "Alarm"} deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: alarm.isActive ? const Color(0xFF334155) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          alarm.formattedTime.split(' ')[0], // Time numbers
                          style: TextStyle(
                            color: alarm.isActive ? Colors.white : Colors.white38,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          alarm.formattedTime.split(' ')[1], // AM/PM
                          style: TextStyle(
                            color: alarm.isActive ? const Color(0xFF7C3AED) : Colors.white30,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      alarm.label.isNotEmpty ? alarm.label : 'Wake Up!',
                      style: TextStyle(
                        color: alarm.isActive ? const Color(0xFF94A3B8) : Colors.white24,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (alarm.repeatDays.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        _repeatDaysLabel(alarm.repeatDays),
                        style: TextStyle(
                          color: alarm.isActive ? const Color(0xFF7C3AED).withOpacity(0.8) : Colors.white24,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Switch(
                value: alarm.isActive,
                activeColor: const Color(0xFF7C3AED),
                activeTrackColor: const Color(0xFF312E81),
                inactiveThumbColor: const Color(0xFF94A3B8),
                inactiveTrackColor: const Color(0xFF475569),
                onChanged: (val) {
                  widget.alarmService.toggleAlarm(alarm.id, val);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _repeatDaysLabel(List<int> days) {
    if (days.length == 7) return 'Everyday';
    if (days.length == 5 && !days.contains(6) && !days.contains(7)) return 'Weekdays';
    if (days.length == 2 && days.contains(6) && days.contains(7)) return 'Weekends';
    
    final daysStr = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.map((d) => daysStr[d - 1]).join(', ');
  }
}

// ── CUSTOM BOTTOM SHEET FOR CREATING ALARMS ──
class AddAlarmSheet extends StatefulWidget {
  final AlarmService alarmService;

  const AddAlarmSheet({
    super.key,
    required this.alarmService,
  });

  @override
  State<AddAlarmSheet> createState() => _AddAlarmSheetState();
}

class _AddAlarmSheetState extends State<AddAlarmSheet> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 7, minute: 0);
  final TextEditingController _labelCtrl = TextEditingController();
  String _selectedTone = 'Radial Beep';
  int _snoozeMinutes = 5;
  final List<int> _repeatDays = [];

  final List<String> _tones = ['Radial Beep', 'Retro Synth', 'Gentle Morning', 'Digital Radar'];

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF7C3AED),
              onPrimary: Colors.white,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _toggleDay(int d) {
    setState(() {
      if (_repeatDays.contains(d)) {
        _repeatDays.remove(d);
      } else {
        _repeatDays.add(d);
      }
    });
  }

  void _save() {
    final newAlarm = Alarm(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      hour: _selectedTime.hour,
      minute: _selectedTime.minute,
      label: _labelCtrl.text.trim(),
      toneName: _selectedTone,
      snoozeMinutes: _snoozeMinutes,
      repeatDays: _repeatDays,
    );

    widget.alarmService.addAlarm(newAlarm);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New Alarm Saved! 🔔'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayHour = _selectedTime.hour == 0
        ? 12
        : (_selectedTime.hour > 12 ? _selectedTime.hour - 12 : _selectedTime.hour);
    final displayMin = _selectedTime.minute.toString().padLeft(2, '0');
    final period = _selectedTime.hour >= 12 ? 'PM' : 'AM';

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sheet bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF475569),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add New Alarm',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Time Selector Plate
            GestureDetector(
              onTap: _selectTime,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF334155), width: 1.5),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$displayHour:$displayMin',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          period,
                          style: const TextStyle(
                            color: Color(0xFF7C3AED),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_calendar_rounded, color: Color(0xFF64748B), size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Tap to change time',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Alarm Label input
            const Text(
              'ALARM LABEL',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _labelCtrl,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF0F172A),
                hintText: 'e.g., Wake up, Medicine, Gym',
                hintStyle: const TextStyle(color: Color(0xFF475569), fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF7C3AED)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Tone selector Dropdown
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ALARM TONE',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedTone,
                            dropdownColor: const Color(0xFF1E293B),
                            items: _tones.map((t) {
                              return DropdownMenuItem<String>(
                                value: t,
                                child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedTone = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Snooze Minutes Input
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SNOOZE DURATION',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _snoozeMinutes,
                            dropdownColor: const Color(0xFF1E293B),
                            items: [5, 10, 15, 20].map((m) {
                              return DropdownMenuItem<int>(
                                value: m,
                                child: Text('$m mins', style: const TextStyle(color: Colors.white, fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _snoozeMinutes = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Repeating Days Selector
            const Text(
              'REPEAT DAYS',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final dayNum = i + 1;
                final dayLabel = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i];
                final active = _repeatDays.contains(dayNum);

                return GestureDetector(
                  onTap: () => _toggleDay(dayNum),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFF7C3AED) : const Color(0xFF0F172A),
                      shape: BoxShape.circle,
                      border: Border.all(color: active ? Colors.transparent : const Color(0xFF334155)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      dayLabel,
                      style: TextStyle(
                        color: active ? Colors.white : const Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.15)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save Alarm', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
