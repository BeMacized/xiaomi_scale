import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:xiaomi_scale/xiaomi-scale.dart';

class ScanningPane extends StatefulWidget {
  @override
  _ScanningPaneState createState() => _ScanningPaneState();
}

class _ScanningPaneState extends State<ScanningPane> {
  StreamSubscription _scanSubscription;
  Map<String, MiScaleDevice> devices = {}; // <Id, MiScaleDevice>
  MiScale _scale = MiScale.instance;

  @override
  void dispose() {
    super.dispose();
    stopDiscovery(dispose: true);
  }

  void startDiscovery() async {
    // Make sure we have location permission required for BLE scanning
    if (!await _checkPermission()) return;
    // Clear device list
    devices = {};
    // Start scanning
    setState(() {
      _scanSubscription = _scale.discoverDevices().listen(
        (device) {
          setState(() {
            devices[device.id] = device;
          });
        },
        onError: (e) {
          print(e);
          stopDiscovery();
        },
        onDone: () => stopDiscovery(),
      );
    });
  }

  void stopDiscovery({dispose = false}) {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    if (!dispose) setState(() {});
  }

  Future<bool> _checkPermission() async {
    PermissionStatus status = await Permission.location.status;
    if (status.isUndetermined || status.isDenied) {
      status = await Permission.location.request();
    }
    return status.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('Start Scanning'),
              onPressed: _scanSubscription == null ? startDiscovery : null,
            ),
            RaisedButton(
              child: Text('Stop Scanning'),
              onPressed: _scanSubscription != null ? stopDiscovery : null,
            ),
          ],
        ),
        Opacity(
          opacity: _scanSubscription != null ? 1 : 0,
          child: Center(child: CircularProgressIndicator()),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: devices.values
                  .map(
                    (device) => _buildDeviceWidget(device),
                  )
                  .toList(),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildDeviceWidget(MiScaleDevice device) {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Name: ' + device.name),
                  Text('Device ID: ' + device.id),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('RSSI: ' + device.rssi.toString() + 'dBm'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
