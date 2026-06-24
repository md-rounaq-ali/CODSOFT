# Task 3: Neon Alarm Clock App

Neon Alarm Clock is an immersive, bedside-style digital clock and alarm management utility built with Flutter. Featuring a live ticking screen, time pickers, active triggers, and custom-synthesized alarm melodies, it is optimized for high performance and visual excellence.

## ✨ Features

- **Ticking Digital Clock**: A high-fidelity bedside clock display showing hours, minutes, ticking seconds, AM/PM indicators, and full calendar dates.
- **Alarm Customizations**:
  - Time selection using modern pickers.
  - Option to name/label alarms.
  - Day repeating selectors (Weekdays, Weekends, specific days).
- **Persistent Alarm List**: Manage your alarms with slide toggles and swipe-to-delete support.
- **Built-in Web Audio API Synthesizer**: Uses custom oscillator codes to play clean alert beeps and melodies (`Radial Beep`, `Retro Synth`, `Gentle Morning`, `Digital Radar`) directly in Chrome without requiring asset downloads.
- **Ringing Overlay Screen**: Custom fullscreen layout featuring pulsating rings with large, easy-to-target **Snooze** and **Dismiss** controls.

## 🛠️ Tech Stack & Packages

- **Framework**: Flutter (Dart)
- **Local Storage**: `shared_preferences`
- **Audio Synthesizer**: JavaScript Web Audio Oscillator (conditionally loaded on Web/Chrome)
- **Formatting**: `intl`

## 🚀 How to Run

1. Navigate to the Task 3 directory:
   ```bash
   cd task3_alarm_clock
   ```
2. Get dependencies:
   ```bash
   flutter pub get
   ```
3. Run on Chrome (or emulator/device):
   ```bash
   flutter run -d chrome
   ```

---

## 📸 Output Previews

> [!TIP]
> Place your actual output images inside the `task3_alarm_clock/outputs/` folder named `home.png` and `ringing.png`.

### 1. Bedside Clock & Alarms List
Main home view displaying live ticking values:
![Alarm Dashboard](outputs/home.png)

### 2. Fullscreen Ringing alert
Showing the pulsating neon rings and controls:
![Active Ringing Alert](outputs/ringing.png)
