import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:xiaomi_scale/xiaomi_scale.dart';

class MeasurementPane extends StatefulWidget {
  @override
  _MeasurementPaneState createState() => _MeasurementPaneState();
}

class _MeasurementPaneState extends State<MeasurementPane> {
  StreamSubscription _measurementSubscription;
  Map<String, MiScaleMeasurement> measurements = {}; // <Id, Measurement>
  MiScale _scale = MiScale.instance;

  @override
  void dispose() {
    super.dispose();
    stopTakingMeasurements(dispose: true);
  }

  void startTakingMeasurements() async {
    // Make sure we have location permission required for BLE scanning
    if (!await _checkPermission()) return;
    // Start taking measurements
    setState(() {
      _measurementSubscription = _scale.takeMeasurements().listen(
        (measurement) {
          setState(() {
            measurements[measurement.id] = measurement;
          });
        },
        onError: (e) {
          print(e);
          stopTakingMeasurements();
        },
        onDone: () => stopTakingMeasurements(),
      );
    });
  }

  void stopTakingMeasurements({dispose = false}) {
    _measurementSubscription?.cancel();
    _measurementSubscription = null;
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
              child: Text('Start Taking Measurements'),
              onPressed: _measurementSubscription == null
                  ? startTakingMeasurements
                  : null,
            ),
            RaisedButton(
              child: Text('Stop Taking Measurements'),
              onPressed: _measurementSubscription != null
                  ? stopTakingMeasurements
                  : null,
            ),
          ],
        ),
        Opacity(
          opacity: _measurementSubscription != null ? 1 : 0,
          child: Center(child: CircularProgressIndicator()),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: measurements.values
                  .map(
                    (measurement) => _buildMeasurementWidget(measurement),
                  )
                  .toList(),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildMeasurementWidget(MiScaleMeasurement measurement) {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    measurement.weight.toStringAsFixed(2) +
                        measurement.unit.toString().split('.')[1],
                  ),
                  Text(
                    measurement.stage.toString().split('.')[1],
                  ),
                  Text(
                    measurement.dateTime.toIso8601String(),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Cancel the measurement if it is still active
                if (measurement.isActive)
                  _scale.cancelMeasurement(measurement.deviceId);
                // Remove the measurement from the list
                setState(() {
                  measurements.remove(measurement.id);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
