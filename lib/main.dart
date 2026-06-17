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

/// Switches between ConnectScreen and ConfigScreen based on connection state.
class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<SerialService>();
    return svc.isConnected ? const _ConfigWithActions() : const ConnectScreen();
  }
}

/// Wraps ConfigScreen with the persistent Save/Reboot/Disconnect action bar.
class _ConfigWithActions extends StatelessWidget {
  const _ConfigWithActions();

  @override
  Widget build(BuildContext context) {
    final svc = context.read<SerialService>();

    Future<void> save() async {
      // ConfigScreen exposes controllers via its state; we trigger save
      // through a GlobalKey approach — simpler: lift controllers up here.
      // Since controllers live in ConfigScreen's State, we use a callback key.
      _configKey.currentState?._save();
    }

    Future<void> reboot() async {
      _configKey.currentState?._reboot();
    }

    return Scaffold(
      body: ConfigScreen(key: _configKey),
      bottomNavigationBar: ActionBar(
        onSave:       () => _configKey.currentState?._save(),
        onReboot:     () => _configKey.currentState?._reboot(),
        onDisconnect: () => svc.disconnect(),
      ),
    );
  }
}

final _configKey = GlobalKey<_ConfigScreenState>();
