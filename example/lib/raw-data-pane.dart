import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:xiaomi_scale/xiaomi-scale.dart';

class RawDataPane extends StatefulWidget {
  @override
  _RawDataPaneState createState() => _RawDataPaneState();
}

class _RawDataPaneState extends State<RawDataPane> {
  StreamSubscription _dataSubscription;
  List<MiScaleData> scaleData = [];
  MiScale _scale = MiScale.instance;

  @override
  void dispose() {
    super.dispose();
    stopTakingData(dispose: true);
  }

  void startTakingData() async {
    // Make sure we have location permission required for BLE scanning
    if (!await _checkPermission()) return;
    // Start taking measurements
    setState(() {
      _dataSubscription = _scale.readScaleData().listen(
        (data) {
          setState(() {
            scaleData.insert(0, data);
            if (scaleData.length > 10) scaleData.removeLast();
          });
        },
        onError: (e) {
          print(e);
          stopTakingData();
        },
        onDone: () => stopTakingData(),
      );
    });
  }

  void stopTakingData({dispose = false}) {
    _dataSubscription?.cancel();
    _dataSubscription = null;
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
              child: Text('Start Reading'),
              onPressed: _dataSubscription == null ? startTakingData : null,
            ),
            RaisedButton(
              child: Text('Stop Reading'),
              onPressed: _dataSubscription != null ? stopTakingData : null,
            ),
          ],
        ),
        Opacity(
          opacity: _dataSubscription != null ? 1 : 0,
          child: Center(child: CircularProgressIndicator()),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text('Last 10 readings:'),
              ]..addAll(
                  scaleData.map(
                    (data) => _buildScaleDataWidget(data),
                  ),
                ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildScaleDataWidget(MiScaleData data) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(data.toString()),
      ),
    );
  }
}
