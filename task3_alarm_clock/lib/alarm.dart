import 'dart:convert';

class Alarm {
  final String id;
  final int hour;
  final int minute;
  final String label;
  final bool isActive;
  final int snoozeMinutes;
  final String toneName;
  final List<int> repeatDays; // 1 = Mon, 7 = Sun

  Alarm({
    required this.id,
    required this.hour,
    required this.minute,
    required this.label,
    this.isActive = true,
    this.snoozeMinutes = 5,
    this.toneName = 'Radial Beep',
    this.repeatDays = const [],
  });

  Alarm copyWith({
    String? id,
    int? hour,
    int? minute,
    String? label,
    bool? isActive,
    int? snoozeMinutes,
    String? toneName,
    List<int>? repeatDays,
  }) {
    return Alarm(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      label: label ?? this.label,
      isActive: isActive ?? this.isActive,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      toneName: toneName ?? this.toneName,
      repeatDays: repeatDays ?? this.repeatDays,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'label': label,
      'isActive': isActive,
      'snoozeMinutes': snoozeMinutes,
      'toneName': toneName,
      'repeatDays': repeatDays,
    };
  }

  factory Alarm.fromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'] ?? '',
      hour: map['hour'] ?? 0,
      minute: map['minute'] ?? 0,
      label: map['label'] ?? '',
      isActive: map['isActive'] ?? true,
      snoozeMinutes: map['snoozeMinutes'] ?? 5,
      toneName: map['toneName'] ?? 'Radial Beep',
      repeatDays: List<int>.from(map['repeatDays'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory Alarm.fromJson(String source) => Alarm.fromMap(json.decode(source));

  String get formattedTime {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }
}
