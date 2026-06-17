import 'package:flutter/material.dart';
import '../../widgets.dart';
import '../../theme.dart';

class IdentityTab extends StatelessWidget {
  final Map<String, TextEditingController> ctrl;
  const IdentityTab({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SectionHeader('Station Identity'),
        FieldRow(label: 'Station Name',   controller: ctrl['node_name']!),
        FieldRow(label: 'Serial Number',  controller: ctrl['serial_num']!),
        const HintLabel('Serial number is editable — useful for inventory tracking.'),
      ],
    );
  }
}
