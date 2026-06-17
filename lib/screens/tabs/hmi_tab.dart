import 'package:flutter/material.dart';
import '../../widgets.dart';

class HmiTab extends StatelessWidget {
  final Map<String, TextEditingController> ctrl;
  const HmiTab({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SectionHeader('Local UART HMI Settings (Hex Codes)'),
        const HintLabel('Format: comma-separated hex (e.g. 0x05, 0x41)'),
        const SizedBox(height: 8),
        FieldRow(label: 'Bin 1 UP',          controller: ctrl['hmi_up1']!),
        FieldRow(label: 'Bin 1 DOWN',        controller: ctrl['hmi_dn1']!),
        FieldRow(label: 'Bin 2 UP',          controller: ctrl['hmi_up2']!),
        FieldRow(label: 'Bin 2 DOWN',        controller: ctrl['hmi_dn2']!),
        FieldRow(label: 'Sensor Request',    controller: ctrl['hmi_req']!),
        FieldRow(label: 'Packet Head Byte',  controller: ctrl['hmi_head']!),
        FieldRow(label: 'Packet Tail Byte',  controller: ctrl['hmi_tail']!),
      ],
    );
  }
}
