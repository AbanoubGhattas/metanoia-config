import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/serial_service.dart';
import '../theme.dart';
import '../widgets.dart';
import 'tabs/identity_tab.dart';
import 'tabs/wifi_tab.dart';
import 'tabs/email_tab.dart';
import 'tabs/battery_tab.dart';
import 'tabs/sensors_tab.dart';
import 'tabs/fan_tab.dart';
import 'tabs/hmi_tab.dart';
import 'tabs/log_tab.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});
  @override
  State<ConfigScreen> createState() => ConfigScreenState();
}

class ConfigScreenState extends State<ConfigScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  late final Map<String, TextEditingController> _ctrl;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 8, vsync: this);

    _ctrl = {
      'node_name':         TextEditingController(),
      'serial_num':        TextEditingController(),
      'wifi_ssid':         TextEditingController(),
      'wifi_pass':         TextEditingController(),
      'smtp_host':         TextEditingController(),
      'smtp_port':         TextEditingController(),
      'author_email':      TextEditingController(),
      'author_pass':       TextEditingController(),
      'recip_email':       TextEditingController(),
      'bat_ratio':         TextEditingController(),
      'bat_low_v':         TextEditingController(),
      'bat_check_ms':      TextEditingController(),
      'trig_us':           TextEditingController(),
      'dist_empty_cm':     TextEditingController(),
      'confirm_rdgs':      TextEditingController(),
      'sensor_period_ms':  TextEditingController(),
      'watchdog_ms':       TextEditingController(),
      'fan_on_temp':       TextEditingController(),
      'fan_off_temp':      TextEditingController(),
      'hmi_up1':           TextEditingController(),
      'hmi_dn1':           TextEditingController(),
      'hmi_up2':           TextEditingController(),
      'hmi_dn2':           TextEditingController(),
      'hmi_req':           TextEditingController(),
      'hmi_head':          TextEditingController(),
      'hmi_tail':          TextEditingController(),
    };

    WidgetsBinding.instance.addPostFrameCallback((_) => _populateFields());
  }

  void _populateFields() {
    final svc = context.read<SerialService>();
    for (final entry in svc.settings.entries) {
      _ctrl[entry.key]?.text = entry.value;
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    for (final c in _ctrl.values) { c.dispose(); }
    super.dispose();
  }

  Future<void> save() async {
    final svc = context.read<SerialService>();
    final fields = _ctrl.map((k, v) => MapEntry(k, v.text));
    await svc.saveSettings(fields);
    svc.settings['fan_on_temp']  = _ctrl['fan_on_temp']!.text;
    svc.settings['fan_off_temp'] = _ctrl['fan_off_temp']!.text;
  }

  Future<void> reboot() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kBG2,
        title: const Text('Reboot?', style: TextStyle(color: kFG, fontFamily: 'monospace')),
        content: const Text('Reboot the station now?',
            style: TextStyle(color: kFGDim, fontFamily: 'monospace')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel', style: TextStyle(color: kFGDim))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kRed, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reboot', style: TextStyle(fontFamily: 'monospace')),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<SerialService>().reboot();
    }
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<SerialService>();

    return Column(
      children: [
        _buildTopBar(svc),
        _buildLiveStrip(svc),
        _buildTabBar(),
        Expanded(child: _buildTabViews(svc)),
      ],
    );
  }

  Widget _buildTopBar(SerialService svc) {
    return Container(
      color: kBG,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(fontFamily: 'monospace', fontSize: 18, fontWeight: FontWeight.bold),
              children: [
                TextSpan(text: 'METANOIA', style: TextStyle(color: kOrange)),
                TextSpan(text: '.llc', style: TextStyle(color: kOrange)),
                TextSpan(text: '  ·  UART Station Config',
                    style: TextStyle(color: kFGDim, fontSize: 12, fontWeight: FontWeight.normal)),
              ],
            ),
          ),
          const Spacer(),
          Text(svc.statusMsg,
              style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: svc.statusOk ? kGreen : kFGDim)),
        ],
      ),
    );
  }

  Widget _buildLiveStrip(SerialService svc) {
    final nodeName = svc.settings['node_name'] ?? '–';
    final sn   = svc.settings['serial_num'] ?? '–';
    final bat  = svc.batV     != null ? '${svc.batV!.toStringAsFixed(2)} V'   : '–';
    final temp = svc.chipTemp != null ? '${svc.chipTemp!.toStringAsFixed(1)}°C' : '–';
    final fan  = svc.fanOn    != null ? (svc.fanOn! ? 'ON' : 'OFF') : '–';
    final s1   = svc.s1Pct   != null ? '${svc.s1Pct}%' : '–';
    final s2   = svc.s2Pct   != null ? '${svc.s2Pct}%' : '–';

    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            StatCell(label: 'NODE', value: nodeName, color: kOrange),
            StatCell(label: 'SN',   value: sn,       color: kFGDim),
            StatCell(label: 'BAT',  value: bat,      color: kGreen),
            StatCell(label: 'TEMP', value: temp,     color: kCyan),
            StatCell(label: 'FAN',  value: fan,      color: kRed),
            StatCell(label: 'ST1',  value: s1,       color: kFG),
            StatCell(label: 'ST2',  value: s2,       color: kFG),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    const tabs = [
      Tab(text: 'Identity'),
      Tab(text: 'WiFi'),
      Tab(text: 'Email'),
      Tab(text: 'Battery'),
      Tab(text: 'Sensors'),
      Tab(text: 'Fan'),
      Tab(text: 'HMI'),
      Tab(text: 'Log'),
    ];
    return Container(
      color: kBG2,
      child: TabBar(
        controller: _tab,
        isScrollable: true,
        tabs: tabs,
        labelStyle: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontFamily: 'monospace', fontSize: 12),
      ),
    );
  }

  Widget _buildTabViews(SerialService svc) {
    return TabBarView(
      controller: _tab,
      children: [
        IdentityTab(ctrl: _ctrl),
        WiFiTab(ctrl: _ctrl),
        EmailTab(ctrl: _ctrl),
        BatteryTab(ctrl: _ctrl, svc: svc),
        SensorsTab(ctrl: _ctrl, svc: svc),
        FanTab(ctrl: _ctrl, svc: svc),
        HmiTab(ctrl: _ctrl),
        LogTab(svc: svc),
      ],
    );
  }
}

class ActionBar extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onReboot;
  final VoidCallback onDisconnect;

  const ActionBar({
    super.key,
    required this.onSave,
    required this.onReboot,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBG2,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save, size: 16),
            label: const Text('Save All'),
            style: ElevatedButton.styleFrom(backgroundColor: kOrange, foregroundColor: Colors.black),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: onReboot,
            icon: const Icon(Icons.restart_alt, size: 16),
            label: const Text('Reboot'),
            style: ElevatedButton.styleFrom(backgroundColor: kRed, foregroundColor: Colors.white),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: onDisconnect,
            icon: const Icon(Icons.usb_off, size: 16, color: kFGDim),
            label: const Text('Disconnect',
                style: TextStyle(color: kFGDim, fontFamily: 'monospace', fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
