import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xiaomi_scale/xiaomi_scale.dart';

import 'util/permissions.dart';

class RawDataPane extends StatefulWidget {
  @override
  _RawDataPaneState createState() => _RawDataPaneState();
}

class _RawDataPaneState extends State<RawDataPane> {
  StreamSubscription? _dataSubscription;
  List<MiScaleData> scaleData = [];
  final _scale = MiScale.instance;

  @override
  void dispose() {
    super.dispose();
    stopTakingData(dispose: true);
  }

  Future<void> startTakingData() async {
    // Make sure we have location permission required for BLE scanning
    if (!await checkPermission()) return;
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
        onDone: stopTakingData,
      );
    });
  }

  void stopTakingData({dispose = false}) {
    _dataSubscription?.cancel();
    _dataSubscription = null;
    if (!dispose) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Start Reading'),
              onPressed: _dataSubscription == null ? startTakingData : null,
            ),
            ElevatedButton(
              child: const Text('Stop Reading'),
              onPressed: _dataSubscription != null ? stopTakingData : null,
            ),
          ],
        ),
        Opacity(
          opacity: _dataSubscription != null ? 1 : 0,
          child: const Center(child: CircularProgressIndicator()),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text('Last 10 readings:'),
                ...scaleData.map(_buildScaleDataWidget),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildScaleDataWidget(MiScaleData data) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(data.toString()),
      ),
    );
  }
}
