import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usb_serial/usb_serial.dart';
import '../services/serial_service.dart';
import '../theme.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});
  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  List<UsbDevice> _devices = [];
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final svc = context.read<SerialService>();
    final devs = await svc.listDevices();
    setState(() => _devices = devs);
  }

  Future<void> _connect(UsbDevice dev) async {
    setState(() => _connecting = true);
    final svc = context.read<SerialService>();
    final ok = await svc.connect(dev);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection failed — check USB permission and station firmware.'),
          backgroundColor: kRed,
        ),
      );
    }
    if (mounted) setState(() => _connecting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBG,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brand header
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontFamily: 'monospace', fontSize: 28, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(text: 'METANOIA', style: TextStyle(color: kOrange)),
                    TextSpan(text: '.llc', style: TextStyle(color: kOrange)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Text('UART Station Config — USB OTG',
                  style: TextStyle(fontFamily: 'monospace', color: kFGDim, fontSize: 13)),
              const SizedBox(height: 32),

              const Text('USB Devices',
                  style: TextStyle(fontFamily: 'monospace', color: kFG, fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              if (_devices.isEmpty)
                const Text('No USB devices found.\nPlug in the station via USB OTG cable.',
                    style: TextStyle(fontFamily: 'monospace', color: kFGDim))
              else
                ..._devices.map((dev) => _DeviceTile(
                      device: dev,
                      onConnect: _connecting ? null : () => _connect(dev),
                    )),

              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _connecting ? null : _refresh,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh Devices'),
              ),

              if (_connecting) ...[
                const SizedBox(height: 24),
                const Row(children: [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: kOrange, strokeWidth: 2)),
                  SizedBox(width: 12),
                  Text('Connecting…', style: TextStyle(fontFamily: 'monospace', color: kFGDim)),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final UsbDevice device;
  final VoidCallback? onConnect;
  const _DeviceTile({required this.device, required this.onConnect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kBG3,
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(Icons.usb, color: kOrange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.productName ?? 'Unknown Device',
                    style: const TextStyle(fontFamily: 'monospace', color: kFG, fontWeight: FontWeight.bold)),
                Text('VID: ${device.vid}  PID: ${device.pid}',
                    style: const TextStyle(fontFamily: 'monospace', color: kFGDim, fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onConnect,
            style: ElevatedButton.styleFrom(backgroundColor: kBlue, foregroundColor: Colors.white),
            child: const Text('Connect', style: TextStyle(fontFamily: 'monospace')),
          ),
        ],
      ),
    );
  }
}
