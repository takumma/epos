import 'package:flutter/material.dart';

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:epos/epos.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _epos = Epos();

  StreamSubscription<EposDevice>? _subscription;

  final List<EposDevice> devices = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();

    _subscription = _epos.discoveryStream.listen((device) {
      setState(() {
        devices.add(device);
      });
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _epos.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _epos.stopDiscovery();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              ElevatedButton(
                onPressed: () async {
                  await _epos.startDiscovery();
                },
                child: const Text('Discovery'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _epos.stopDiscovery();
                },
                child: const Text('Stop Discovery'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return ListTile(
                      title: Text(device.deviceName),
                      subtitle: Text(device.target),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          try {
                            final printer = await _epos.connect(device);
                            if (!context.mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PrintPage(printer: printer),
                              ),
                            );
                          } on PlatformException catch (e) {
                            debugPrint('Failed to connect: $e');
                          }
                        },
                        child: const Text('Connect'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrintPage extends StatelessWidget {
  final EposPrinter printer;
  const PrintPage({super.key, required this.printer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Print Page')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              try {
                final job = printer.createPrintJob();
                job
                  ..textLang(EposTextLanguage.ja)
                  ..feed(1)
                  ..textAlign(EposTextAlign.center)
                  ..text("Hello World!\n")
                  ..text("텐나 서점\n")
                  ..textAlign(EposTextAlign.left)
                  ..text("어느 사소설 작가의 일지 — 야성의 장, 요도의 장, 불굴의 장\n")
                  ..text("500엔\n")
                  ..cut();
                await printer.print(job);
                debugPrint('Printed successfully');
              } on PlatformException catch (e) {
                debugPrint('Failed to connect: $e');
              }
            },
            child: const Text('Print'),
          ),
        ],
      ),
    );
  }
}
