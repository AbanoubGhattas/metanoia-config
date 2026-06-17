# METANOIA.llc — Station Config (Flutter Android)

Android port of the desktop `cnfg_usb.py` tool.  
Connects to the ESP32 station over **USB OTG** serial at 115200 baud, same JSON command protocol.

---

## Prerequisites

- Flutter SDK ≥ 3.0  →  https://docs.flutter.dev/get-started/install
- Android Studio (for SDK / emulator) or a physical Android device
- USB OTG cable (USB-A female → USB-C male, or appropriate for your phone)

---

## Build & Install

```bash
# 1. Get dependencies
flutter pub get

# 2. Run on connected Android device (USB debugging enabled)
flutter run

# 3. Build release APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

Install the APK on the device:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## USB Permission

On first connection Android will show a popup:
> "Allow METANOIA Config to access the USB device?"

Tap **OK**. The app also registers for `USB_DEVICE_ATTACHED` so it can
auto-launch when you plug in a known device (CP210x, CH340, FTDI, PL2303).

To add a new chip VID/PID, edit:
```
android/app/src/main/res/xml/device_filter.xml
```

---

## Supported USB-Serial chips

| Chip      | Common boards         |
|-----------|-----------------------|
| CP210x    | Most ESP32 devboards  |
| CH340/341 | NodeMCU, cheap clones |
| FTDI FT232| Adafruit, Sparkfun    |
| PL2303    | Older breakout boards |

---

## App structure

```
lib/
  main.dart                  Entry point, Provider setup, screen routing
  theme.dart                 METANOIA dark/orange palette
  widgets.dart               Shared FieldRow, SectionHeader, StatCell …
  services/
    serial_service.dart      All USB serial I/O, JSON protocol, live poll
  screens/
    connect_screen.dart      USB device picker
    config_screen.dart       Main tabbed config UI + action bar
    tabs/
      identity_tab.dart
      wifi_tab.dart
      email_tab.dart
      battery_tab.dart
      sensors_tab.dart
      fan_tab.dart
      hmi_tab.dart
      log_tab.dart
```

---

## JSON protocol (same as desktop)

All commands are newline-terminated JSON objects sent at 115200 baud.

| Command          | Payload                        | Response              |
|------------------|--------------------------------|-----------------------|
| `connect`        | —                              | `{"ok": true}`        |
| `get_settings`   | —                              | `{key: value, …}`     |
| `set_settings`   | `{"payload": {key: value, …}}` | `{"ok": true}`        |
| `status`         | —                              | `{bat_v, chip_temp, fan_on, s1_pct, s2_pct}` |
| `get_log`        | —                              | `{"log": "…"}`        |
| `append_log`     | `{"entry": "…"}`               | `{"ok": true}`        |
| `test_email`     | —                              | `{"ok": true}`        |
| `reboot`         | —                              | *(no response)*       |
| `disconnect`     | —                              | *(no response)*       |
