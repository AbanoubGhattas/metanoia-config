import 'package:flutter/material.dart';
import 'theme.dart';

/// Labelled text field that writes into [controller].
class FieldRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;

  const FieldRow({
    super.key,
    required this.label,
    required this.controller,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: Text(label,
                style: const TextStyle(
                    fontFamily: 'monospace', color: kFGDim, fontSize: 13)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              style: const TextStyle(fontFamily: 'monospace', color: kFG, fontSize: 13),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Orange section heading.
class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
        child: Text(title,
            style: const TextStyle(
                fontFamily: 'monospace',
                color: kOrange,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
      );
}

/// Coloured stat cell used in the live strip.
class StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const StatCell({super.key, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: const TextStyle(
                    fontFamily: 'monospace', color: kFGDim, fontSize: 10, fontWeight: FontWeight.bold)),
            Text(value,
                style: TextStyle(
                    fontFamily: 'monospace', color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      );
}

/// Hint note in dim text.
class HintLabel extends StatelessWidget {
  final String text;
  const HintLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Text('★  $text',
            style: const TextStyle(fontFamily: 'monospace', color: kFGDim, fontSize: 12)),
      );
}
