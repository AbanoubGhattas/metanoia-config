import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/serial_service.dart';
import 'screens/connect_screen.dart';
import 'screens/config_screen.dart';
import 'theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SerialService(),
      child: const MetanoiaApp(),
    ),
  );
}

class MetanoiaApp extends StatelessWidget {
  const MetanoiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'METANOIA Station Config',
      theme: buildTheme(),
      debugShowCheckedModeBanner: false,
      home: const _Root(),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<SerialService>();
    return svc.isConnected ? const _ConfigWithActions() : const ConnectScreen();
  }
}

class _ConfigWithActions extends StatefulWidget {
  const _ConfigWithActions();

  @override
  State<_ConfigWithActions> createState() => _ConfigWithActionsState();
}

class _ConfigWithActionsState extends State<_ConfigWithActions> {
  final _configKey = GlobalKey<ConfigScreenState>();

  @override
  Widget build(BuildContext context) {
    final svc = context.read<SerialService>();
    return Scaffold(
      body: ConfigScreen(key: _configKey),
      bottomNavigationBar: ActionBar(
        onSave:       () => _configKey.currentState?.save(),
        onReboot:     () => _configKey.currentState?.reboot(),
        onDisconnect: () => svc.disconnect(),
      ),
    );
  }
}
