import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:usb_serial/usb_serial.dart';

/// Mirrors the Python _send_cmd / _poll_loop logic.
/// All serial I/O lives here; UI never touches the port directly.
class SerialService extends ChangeNotifier {
  UsbPort? _port;
  StreamSubscription? _subscription;
  String _readBuffer = '';

  bool get isConnected => _port != null;

  // Live telemetry (updated by poll)
  double? batV;
  double? chipTemp;
  bool? fanOn;
  int? s1Pct;
  int? s2Pct;

  // Settings map (key → value string)
  Map<String, String> settings = {};

  // Maintenance log text
  String maintLog = '';

  // Status message shown in the top bar
  String statusMsg = '⬤  Not connected';
  bool statusOk = false;

  // Fan decision log lines (newest first, max 20)
  List<String> fanLog = [];
  DateTime? _lastFanLogTime;

  Timer? _pollTimer;

  // ── Device list ────────────────────────────────────────────
  Future<List<UsbDevice>> listDevices() async {
    return await UsbSerial.listDevices();
  }

  // ── Connect ────────────────────────────────────────────────
  Future<bool> connect(UsbDevice device) async {
    try {
      _port = await device.create();
      if (_port == null) return false;

      bool opened = await _port!.open();
      if (!opened) { _port = null; return false; }

      await _port!.setDTR(true);
      await _port!.setRTS(true);
      await _port!.setPortParameters(
        115200,
        UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1,
        UsbPort.PARITY_NONE,
      );

      // Buffer incoming bytes into lines
      _subscription = _port!.inputStream!.listen((Uint8List data) {
        _readBuffer += utf8.decode(data, allowMalformed: true);
      });

      // Wait for ESP32 reset (mirrors time.sleep(1.5) in Python)
      await Future.delayed(const Duration(milliseconds: 1500));

      final resp = await _sendCmd({'cmd': 'connect'});
      if (resp == null || resp['ok'] != true) {
        await disconnect();
        return false;
      }

      statusMsg = '⬤  Connected (Config Mode)';
      statusOk = true;

      // Load settings
      final s = await _sendCmd({'cmd': 'get_settings'});
      if (s != null) {
        settings = s.map((k, v) => MapEntry(k.toString(), v.toString()));
      }

      // Load maintenance log
      await refreshLog();

      // Start live poll (every 2 s, mirrors Python poll_loop)
      _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());

      notifyListeners();
      return true;
    } catch (e) {
      statusMsg = '✖  Serial Error: $e';
      statusOk = false;
      _port = null;
      notifyListeners();
      return false;
    }
  }

  // ── Disconnect ─────────────────────────────────────────────
  Future<void> disconnect() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    await _sendCmd({'cmd': 'disconnect'});
    await _subscription?.cancel();
    await _port?.close();
    _port = null;
    statusMsg = '⬤  Disconnected';
    statusOk = false;
    notifyListeners();
  }

  // ── Save settings ──────────────────────────────────────────
  Future<bool> saveSettings(Map<String, String> fields) async {
    final resp = await _sendCmd({'cmd': 'set_settings', 'payload': fields});
    final ok = resp != null && resp['ok'] == true;
    statusMsg = ok ? '✔  Saved to NVS!' : '✖  Save failed';
    statusOk = ok;
    notifyListeners();
    return ok;
  }

  // ── Reboot ─────────────────────────────────────────────────
  Future<void> reboot() async {
    await _sendCmd({'cmd': 'reboot'});
    await disconnect();
  }

  // ── Test email ─────────────────────────────────────────────
  Future<bool> testEmail() async {
    final resp = await _sendCmd({'cmd': 'test_email'});
    return resp != null && resp['ok'] == true;
  }

  // ── Maintenance log ────────────────────────────────────────
  Future<void> refreshLog() async {
    final resp = await _sendCmd({'cmd': 'get_log'});
    maintLog = resp?['log'] ?? '(no entries)';
    notifyListeners();
  }

  Future<bool> appendLog(String entry) async {
    final ts = DateTime.now().toString().substring(0, 16);
    final resp = await _sendCmd({'cmd': 'append_log', 'entry': '[$ts] $entry'});
    final ok = resp != null && resp['ok'] == true;
    if (ok) await refreshLog();
    return ok;
  }

  // ── Internal: JSON command ──────────────────────────────────
  Future<Map<String, dynamic>?> _sendCmd(Map<String, dynamic> cmd) async {
    if (_port == null) return null;
    try {
      final payload = jsonEncode(cmd) + '\n';
      await _port!.write(Uint8List.fromList(utf8.encode(payload)));

      // Wait up to 2 s for a complete JSON line
      final deadline = DateTime.now().add(const Duration(seconds: 2));
      while (DateTime.now().isBefore(deadline)) {
        final nl = _readBuffer.indexOf('\n');
        if (nl != -1) {
          final line = _readBuffer.substring(0, nl).trim();
          _readBuffer = _readBuffer.substring(nl + 1);
          if (line.isNotEmpty) return jsonDecode(line) as Map<String, dynamic>;
        }
        await Future.delayed(const Duration(milliseconds: 50));
      }
    } catch (_) {}
    return null;
  }

  // ── Live poll (mirrors _update_live) ──────────────────────
  Future<void> _poll() async {
    if (_port == null) return;
    final d = await _sendCmd({'cmd': 'status'});
    if (d == null) return;

    final bat = d['bat_v'];
    batV = bat is num ? bat.toDouble() : null;

    final temp = d['chip_temp'];
    chipTemp = temp is num ? temp.toDouble() : null;

    final fan = d['fan_on'];
    if (fan is bool) {
      fanOn = fan;
      _maybeAppendFanLog(fan);
    }

    final s1 = d['s1_pct'];
    final s2 = d['s2_pct'];
    s1Pct = s1 is int ? s1 : null;
    s2Pct = s2 is int ? s2 : null;

    notifyListeners();
  }

  void _maybeAppendFanLog(bool fan) {
    final now = DateTime.now();
    if (_lastFanLogTime != null &&
        now.difference(_lastFanLogTime!).inSeconds < 60) return;
    _lastFanLogTime = now;

    final ts = '${now.hour.toString().padLeft(2,'0')}:'
               '${now.minute.toString().padLeft(2,'0')}:'
               '${now.second.toString().padLeft(2,'0')}';

    final t = chipTemp ?? 0.0;
    final onT = double.tryParse(settings['fan_on_temp'] ?? '') ?? 48.0;
    final offT = double.tryParse(settings['fan_off_temp'] ?? '') ?? 46.0;

    String reason;
    if (fan && t >= onT) {
      reason = 'Temp ${t.toStringAsFixed(1)}°C ≥ ${onT}°C → FAN ON';
    } else if (!fan && t <= offT) {
      reason = 'Temp ${t.toStringAsFixed(1)}°C ≤ ${offT}°C → FAN OFF';
    } else {
      reason = 'Temp ${t.toStringAsFixed(1)}°C — no change (Fan ${fan ? "ON" : "OFF"})';
    }

    fanLog.insert(0, '[$ts]  $reason');
    if (fanLog.length > 20) fanLog.removeLast();
  }
}
