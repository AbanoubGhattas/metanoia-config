import 'package:flutter/material.dart';
import '../../widgets.dart';

class WiFiTab extends StatelessWidget {
  final Map<String, TextEditingController> ctrl;
  const WiFiTab({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SectionHeader('WiFi Credentials'),
        FieldRow(label: 'SSID',     controller: ctrl['wifi_ssid']!),
        FieldRow(label: 'Password', controller: ctrl['wifi_pass']!, obscure: true),
        const HintLabel('Save WiFi changes then Reboot — station reconnects on new credentials.'),
      ],
    );
  }
}
