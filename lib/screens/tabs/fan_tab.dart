import 'package:flutter/material.dart';
import '../../widgets.dart';
import '../../theme.dart';
import '../../services/serial_service.dart';

class FanTab extends StatelessWidget {
  final Map<String, TextEditingController> ctrl;
  final SerialService svc;
  const FanTab({super.key, required this.ctrl, required this.svc});

  @override
  Widget build(BuildContext context) {
    final temp = svc.chipTemp != null ? '${svc.chipTemp!.toStringAsFixed(1)}°C' : '–';
    final fan  = svc.fanOn   != null ? (svc.fanOn! ? 'ON' : 'OFF') : '–';
    final fanColor = svc.fanOn == true ? kRed : kGreen;

    return ListView(
      children: [
        const SectionHeader('Fan Control — IO13 (active HIGH)'),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'Fan uses ESP32 internal chip temperature.\n'
            'Turns ON at fan_on_temp, OFF at fan_off_temp.',
            style: TextStyle(fontFamily: 'monospace', color: kFGDim, fontSize: 12),
          ),
        ),
        FieldRow(label: 'Fan ON Temperature (°C)',  controller: ctrl['fan_on_temp']!),
        FieldRow(label: 'Fan OFF Temperature (°C)', controller: ctrl['fan_off_temp']!),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: kBG3, borderRadius: BorderRadius.circular(6)),
          child: Row(
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Live Chip Temp', style: TextStyle(fontFamily: 'monospace', color: kFGDim, fontSize: 12)),
                Text(temp, style: const TextStyle(fontFamily: 'monospace', color: kCyan, fontSize: 22, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(width: 32),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Fan', style: TextStyle(fontFamily: 'monospace', color: kFGDim, fontSize: 12)),
                Text(fan, style: TextStyle(fontFamily: 'monospace', color: fanColor, fontSize: 22, fontWeight: FontWeight.bold)),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Fan Decision Log (recorded every 60s):',
              style: TextStyle(fontFamily: 'monospace', color: kFGDim, fontSize: 12)),
        ),
        const SizedBox(height: 6),
        Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: kBG3,
            border: Border.all(color: kBorder),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ListView.builder(
            reverse: false,
            itemCount: svc.fanLog.length,
            itemBuilder: (_, i) => Text(
              svc.fanLog[i],
              style: const TextStyle(fontFamily: 'monospace', color: kFG, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
