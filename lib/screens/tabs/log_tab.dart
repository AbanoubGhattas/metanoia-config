import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets.dart';
import '../../theme.dart';
import '../../services/serial_service.dart';

class LogTab extends StatefulWidget {
  final SerialService svc;
  const LogTab({super.key, required this.svc});
  @override
  State<LogTab> createState() => _LogTabState();
}

class _LogTabState extends State<LogTab> {
  final _entryCtrl = TextEditingController();
  String _logStatus = '';
  Color _logColor = kGreen;

  Future<void> _append() async {
    final text = _entryCtrl.text.trim();
    if (text.isEmpty) return;
    final ok = await context.read<SerialService>().appendLog(text);
    setState(() {
      _logStatus = ok ? '✔  Entry saved' : '✖  Failed';
      _logColor  = ok ? kGreen : kRed;
    });
    if (ok) _entryCtrl.clear();
  }

  Future<void> _refresh() async {
    await context.read<SerialService>().refreshLog();
    setState(() {
      _logStatus = 'Refreshed';
      _logColor  = kFGDim;
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<SerialService>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader('Maintenance Log'),
        const HintLabel('Stored on station NVS (≤ 3 KB). Timestamped automatically.'),
        const SizedBox(height: 12),
        const Text('Existing entries:', style: TextStyle(fontFamily: 'monospace', color: kFGDim, fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          height: 200,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: kBG3,
            border: Border.all(color: kBorder),
            borderRadius: BorderRadius.circular(4),
          ),
          child: SingleChildScrollView(
            reverse: true,
            child: Text(svc.maintLog,
                style: const TextStyle(fontFamily: 'monospace', color: kFG, fontSize: 12)),
          ),
        ),
        const SizedBox(height: 16),
        const Text('New entry:', style: TextStyle(fontFamily: 'monospace', color: kFGDim, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: _entryCtrl,
          style: const TextStyle(fontFamily: 'monospace', color: kFG, fontSize: 13),
          onSubmitted: (_) => _append(),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _append,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Append Entry'),
              style: ElevatedButton.styleFrom(backgroundColor: kGreen, foregroundColor: Colors.black),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh Log'),
              style: ElevatedButton.styleFrom(backgroundColor: kBlue, foregroundColor: Colors.white),
            ),
            const SizedBox(width: 16),
            Text(_logStatus, style: TextStyle(fontFamily: 'monospace', color: _logColor, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
