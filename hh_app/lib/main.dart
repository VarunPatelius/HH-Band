/* 
Made by Varun Patel - BlueHandCoding
Last Updated: Wed April 19, 2023

https://www.varunpatel.net/
https://www.bluehandcoding.com/

All credits must be given to original author
*/

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HH Band - SFT Project',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'HH Band - SFT Project'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  late BluetoothDevice _arduinoDevice;
  late BluetoothCharacteristic _dataSource;

  final _audioPlayer = AudioPlayer();

  bool _deviceLocated = false;
  bool _deviceConnected = false;
  bool _readingData = false;

  final StreamController _dataStream = StreamController<List>();
  late StreamSubscription _subscription;

  String status = "Click Find Player";

  @override
  void initState() {
    super.initState();

    _audioPlayer.setAsset("assets/scream.mp3");
    _audioPlayer.setLoopMode(LoopMode.all);

    Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      if (_deviceConnected && _readingData) {
        try {
          _dataStream.add(await _dataSource.read());
        } catch (PlatformException) {}
      }
    });

    _subscription = _dataStream.stream.listen((event) {
      setState(() {
        status = "Temperature: ${event[0]}°F";
        if (event[0] > 75) {
          _audioPlayer.play();
        } else if (event[0] < 75 || !_readingData) {
          _audioPlayer.stop();
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
    _dataStream.close();
    _arduinoDevice.disconnect();
  }

  void _findDevice() {
    _flutterBlue.startScan(timeout: const Duration(seconds: 4));
    _flutterBlue.scanResults.listen(
      (results) {
        for (ScanResult r in results) {
          print(r.device.name);
          if (r.device.name == "Arduino") {
            _arduinoDevice = r.device;
            _flutterBlue.stopScan();
            _deviceLocated = true;

            setState(() {
              status = "Arduino Device Found";
            });
            break;
          }
        }
      },
    );
  }

  void _connectToDevice() async {
    if (_deviceLocated) {
      await _arduinoDevice.connect();

      List<BluetoothService> services = await _arduinoDevice.discoverServices();
      services.forEach((service) async {
        var characteristics = service.characteristics;
        _dataSource = characteristics[0];
      });

      _deviceConnected = true;

      setState(() {
        status = "Connected To Arduino";
      });
    }
  }

  void _disconnectFromDevice() {
    if (_deviceConnected) {
      _arduinoDevice.disconnect();
      _deviceConnected = false;
      _readingData = false;
      _audioPlayer.stop();

      setState(() {
        status = "Disconnected From Arduino";
      });
    }
  }

  void _readData() async {
    _readingData = !_readingData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              status,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            CupertinoButton.filled(
              onPressed: _deviceLocated ? null : _findDevice,
              child: const Text("Find Player"),
            ),
            CupertinoButton.filled(
              onPressed: (_deviceLocated && !_deviceConnected)
                  ? _connectToDevice
                  : null,
              child: const Text("Connect to Player"),
            ),
            CupertinoButton.filled(
              onPressed: (_deviceConnected && !_readingData)
                  ? _disconnectFromDevice
                  : null,
              child: const Text("Disconnect from Player"),
            ),
            CupertinoButton.filled(
              onPressed: _deviceConnected ? _readData : null,
              child: _readingData
                  ? Text("Stop Monitoring")
                  : Text("Start Monitoring"),
            )
          ],
        ),
      ),
    );
  }
}
