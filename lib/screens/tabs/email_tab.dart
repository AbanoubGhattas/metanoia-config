import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets.dart';
import '../../theme.dart';
import '../../services/serial_service.dart';

class EmailTab extends StatefulWidget {
  final Map<String, TextEditingController> ctrl;
  const EmailTab({super.key, required this.ctrl});
  @override
  State<EmailTab> createState() => _EmailTabState();
}

class _EmailTabState extends State<EmailTab> {
  String _emailStatus = '';
  Color _emailColor = kGreen;

  Future<void> _testEmail() async {
    setState(() { _emailStatus = 'Sending…'; _emailColor = kFGDim; });
    final ok = await context.read<SerialService>().testEmail();
    setState(() {
      _emailStatus = ok ? '✔  Test email queued!' : '✖  Failed';
      _emailColor  = ok ? kGreen : kRed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SectionHeader('SMTP Settings'),
        FieldRow(label: 'SMTP Host',        controller: widget.ctrl['smtp_host']!),
        FieldRow(label: 'SMTP Port',        controller: widget.ctrl['smtp_port']!),
        FieldRow(label: 'Sender Email',     controller: widget.ctrl['author_email']!),
        FieldRow(label: 'Sender App-Pass',  controller: widget.ctrl['author_pass']!, obscure: true),
        FieldRow(label: 'Recipient Email',  controller: widget.ctrl['recip_email']!),
        const SectionHeader('Test Email'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: _testEmail,
                icon: const Icon(Icons.send, size: 16),
                label: const Text('Send Test Email'),
                style: ElevatedButton.styleFrom(backgroundColor: kBlue, foregroundColor: Colors.white),
              ),
              const SizedBox(width: 16),
              Text(_emailStatus, style: TextStyle(fontFamily: 'monospace', color: _emailColor, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}
