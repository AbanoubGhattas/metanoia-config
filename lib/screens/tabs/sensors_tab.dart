import 'package:flutter/material.dart';
import '../../widgets.dart';
import '../../theme.dart';
import '../../services/serial_service.dart';

class SensorsTab extends StatelessWidget {
  final Map<String, TextEditingController> ctrl;
  final SerialService svc;
  const SensorsTab({super.key, required this.ctrl, required this.svc});

  @override
  Widget build(BuildContext context) {
    final s1 = svc.s1Pct != null ? '${svc.s1Pct}%' : '–';
    final s2 = svc.s2Pct != null ? '${svc.s2Pct}%' : '–';
    return ListView(
      children: [
        const SectionHeader('Ultrasonic Settings'),
        FieldRow(label: 'Trigger Pulse (µs)',    controller: ctrl['trig_us']!),
        FieldRow(label: 'Empty Distance (cm)',   controller: ctrl['dist_empty_cm']!),
        FieldRow(label: 'Confirm Readings',      controller: ctrl['confirm_rdgs']!),
        FieldRow(label: 'Sensor Period (ms)',    controller: ctrl['sensor_period_ms']!),
        FieldRow(label: 'Watchdog Timeout (ms)', controller: ctrl['watchdog_ms']!),
        const HintLabel('Confirm Readings: consecutive identical reads needed to accept a state change.'),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: kBG3, borderRadius: BorderRadius.circular(6)),
          child: Row(
            children: [
              _LiveStat('Station 1 Fill', s1),
              const SizedBox(width: 32),
              _LiveStat('Station 2 Fill', s2),
            ],
          ),
        ),
      ],
    );
  }
}

class _LiveStat extends StatelessWidget {
  final String label;
  final String value;
  const _LiveStat(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'monospace', color: kFGDim, fontSize: 12)),
          Text(value,  style: const TextStyle(fontFamily: 'monospace', color: kCyan,  fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      );
}
