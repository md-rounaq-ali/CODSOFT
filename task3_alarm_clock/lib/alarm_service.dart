import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'alarm.dart';

class AlarmService extends ChangeNotifier {
  static const _key = 'saved_alarms';
  List<Alarm> _alarms = [];
  Timer? _checkTimer;
  Alarm? _ringingAlarm;

  // Callback to open Ring Screen in UI
  Function(Alarm)? onAlarmTriggered;

  List<Alarm> get alarms => _alarms;
  Alarm? get ringingAlarm => _ringingAlarm;

  AlarmService() {
    _loadAlarms();
    _startClockLoop();
  }

  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    _alarms = raw.map((s) => Alarm.fromJson(s)).toList();
    notifyListeners();
  }

  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = _alarms.map((a) => a.toJson()).toList();
    await prefs.setStringList(_key, raw);
    notifyListeners();
  }

  Future<void> addAlarm(Alarm alarm) async {
    _alarms.add(alarm);
    await _saveAlarms();
  }

  Future<void> updateAlarm(Alarm updated) async {
    final idx = _alarms.indexWhere((a) => a.id == updated.id);
    if (idx != -1) {
      _alarms[idx] = updated;
      await _saveAlarms();
    }
  }

  Future<void> toggleAlarm(String id, bool active) async {
    final idx = _alarms.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _alarms[idx] = _alarms[idx].copyWith(isActive: active);
      await _saveAlarms();
    }
  }

  Future<void> deleteAlarm(String id) async {
    _alarms.removeWhere((a) => a.id == id);
    await _saveAlarms();
  }

  void _startClockLoop() {
    _checkTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkForTrigger();
    });
  }

  // To prevent firing multiple times in the same minute
  String _lastTriggeredId = '';
  int _lastTriggeredMinute = -1;

  void _checkForTrigger() {
    final now = DateTime.now();
    // Only check once per minute changes
    if (now.minute == _lastTriggeredMinute) return;

    for (var alarm in _alarms) {
      if (alarm.isActive && alarm.hour == now.hour && alarm.minute == now.minute) {
        // If it's a repeating alarm, check if today is selected
        if (alarm.repeatDays.isNotEmpty && !alarm.repeatDays.contains(now.weekday)) {
          continue;
        }
        
        // Trigger alarm
        _lastTriggeredMinute = now.minute;
        _lastTriggeredId = alarm.id;
        _triggerAlarm(alarm);
        break;
      }
    }
  }

  void _triggerAlarm(Alarm alarm) {
    _ringingAlarm = alarm;
    notifyListeners();
    if (onAlarmTriggered != null) {
      onAlarmTriggered!(alarm);
    }
  }

  void snoozeAlarm() {
    if (_ringingAlarm == null) return;
    final now = DateTime.now();
    
    // Add snooze duration to schedule a temporary alarm
    final snoozeTime = now.add(Duration(minutes: _ringingAlarm!.snoozeMinutes));
    
    final snoozedAlarm = Alarm(
      id: 'snooze_${_ringingAlarm!.id}',
      hour: snoozeTime.hour,
      minute: snoozeTime.minute,
      label: '${_ringingAlarm!.label} (Snoozed)',
      isActive: true,
      snoozeMinutes: _ringingAlarm!.snoozeMinutes,
      toneName: _ringingAlarm!.toneName,
      repeatDays: [], // One-off
    );

    // Add temporary snooze alarm, then dismiss ringing
    addAlarm(snoozedAlarm);
    dismissAlarm();
  }

  void dismissAlarm() {
    if (_ringingAlarm == null) return;
    
    // If it's a one-off (non-repeating) alarm, turn it off
    if (_ringingAlarm!.repeatDays.isEmpty && !_ringingAlarm!.id.startsWith('snooze_')) {
      toggleAlarm(_ringingAlarm!.id, false);
    }

    // If it is a temporary snooze alarm, remove it after dismissal
    if (_ringingAlarm!.id.startsWith('snooze_')) {
      deleteAlarm(_ringingAlarm!.id);
    }

    _ringingAlarm = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }
}
