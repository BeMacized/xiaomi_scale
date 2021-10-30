import 'dart:async';

import 'package:flutter/material.dart';
import 'package:xiaomi_scale/xiaomi_scale.dart';

import 'util/permissions.dart';

class MeasurementPane extends StatefulWidget {
  @override
  _MeasurementPaneState createState() => _MeasurementPaneState();
}

class _MeasurementPaneState extends State<MeasurementPane> {
  StreamSubscription? _measurementSubscription;
  Map<String, MiScaleMeasurement> measurements = {}; // <Id, Measurement>
  final _scale = MiScale.instance;

  @override
  void dispose() {
    super.dispose();
    stopTakingMeasurements(dispose: true);
  }

  Future<void> startTakingMeasurements() async {
    // Make sure we have location permission required for BLE scanning
    if (!await checkPermission()) return;
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
        onDone: stopTakingMeasurements,
      );
    });
  }

  void stopTakingMeasurements({dispose = false}) {
    _measurementSubscription?.cancel();
    _measurementSubscription = null;
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
            Expanded(
              child: ElevatedButton(
                child: const Text(
                  'Start Taking Measurements',
                  textAlign: TextAlign.center,
                ),
                onPressed: _measurementSubscription == null
                    ? startTakingMeasurements
                    : null,
              ),
            ),
            Expanded(
              child: ElevatedButton(
                child: const Text(
                  'Stop Taking Measurements',
                  textAlign: TextAlign.center,
                ),
                onPressed: _measurementSubscription != null
                    ? stopTakingMeasurements
                    : null,
              ),
            ),
          ],
        ),
        Opacity(
          opacity: _measurementSubscription != null ? 1 : 0,
          child: const Center(child: CircularProgressIndicator()),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children:
                  measurements.values.map(_buildMeasurementWidget).toList(),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildMeasurementWidget(MiScaleMeasurement measurement) {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  if (measurement.extraData != null) ...[
                    Container(
                      height: 2,
                      color: Colors.grey,
                    ),
                    Text(
                      'bodyFat: ${measurement.extraData.bodyFat}',
                    ),
                    Text(
                      'boneMass: ${measurement.extraData.boneMass}',
                    ),
                    Text(
                      'lbmCoefficient: ${measurement.extraData.lbmCoefficient}',
                    ),
                    Text(
                      'muscleMass: ${measurement.extraData.muscleMass}',
                    ),
                    Text(
                      'BMI: ${measurement.extraData.bmi}',
                    ),
                    Text(
                      'water: ${measurement.extraData.water}',
                    ),
                    Text(
                      'visceralFat: ${measurement.extraData.visceralFat}',
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                final deviceId = measurement.deviceId;
                // Cancel the measurement if it is still active
                if (measurement.isActive && deviceId != null)
                  _scale.cancelMeasurement(deviceId);
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
