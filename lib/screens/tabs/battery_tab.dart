import 'package:flutter/material.dart';
import '../../widgets.dart';
import '../../theme.dart';
import '../../services/serial_service.dart';

class BatteryTab extends StatelessWidget {
  final Map<String, TextEditingController> ctrl;
  final SerialService svc;
  const BatteryTab({super.key, required this.ctrl, required this.svc});

  @override
  Widget build(BuildContext context) {
    final bat = svc.batV != null ? '${svc.batV!.toStringAsFixed(2)} V' : '–';
    return ListView(
      children: [
        const SectionHeader('Battery Monitoring'),
        FieldRow(label: 'Voltage Divider Ratio',    controller: ctrl['bat_ratio']!),
        FieldRow(label: 'Low Voltage Threshold (V)', controller: ctrl['bat_low_v']!),
        FieldRow(label: 'Check Interval (ms)',       controller: ctrl['bat_check_ms']!),
        const HintLabel('Default ratio 13.95 for 110 kΩ + 9.1 kΩ divider on BAT_PIN (IO34).'),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: kBG3, borderRadius: BorderRadius.circular(6)),
          child: Row(
            children: [
              const Text('Live Battery Voltage:', style: TextStyle(fontFamily: 'monospace', color: kFGDim)),
              const SizedBox(width: 16),
              Text(bat, style: const TextStyle(fontFamily: 'monospace', color: kGreen, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}
