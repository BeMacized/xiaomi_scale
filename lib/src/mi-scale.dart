import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'mi-scale-data.dart';
import 'mi-scale-device.dart';
import 'mi-scale-measurement.dart';

final Uuid BODY_COMPOSITION_SERVICE = Uuid([0x18, 0x1B]);

class MiScale {
  static MiScale _instance;

  /// Obtain the singleton [MiScale] instance
  static MiScale get instance {
    if (_instance == null) _instance = MiScale._internal();
    return _instance;
  }

  final _ble = FlutterReactiveBle();
  Map<String, MiScaleMeasurement> _activeMeasurements = {};

  MiScale._internal();

  /// Cancel any active measurement for the given device
  ///
  /// Read 'active measurement' as a measurement not on the [MiScaleMeasurementStage.MEASURED] stage.
  /// NOTE: If a user steps off the scale before the [MiScaleMeasurementStage.STABILIZED] stage is reached, the measurement will remain active.
  /// In this case, the measurement will have to be canceled before a new measurement is to be started.
  void cancelMeasurement(String deviceId) {
    _activeMeasurements.remove(deviceId);
  }

  /// Listens for weight measurements
  ///
  /// Provides a stream of [MiScaleMeasurement] instances.
  /// Multiple instances are emitted for the same measurement throughout the progress of the measurement to denote changes.
  /// The measurements continue to be taken until the returned stream is cancelled.
  Stream<MiScaleMeasurement> takeMeasurements() {
    StreamSubscription dataSubscription;
    StreamSubscription cleanUpSubscription;
    StreamController<MiScaleMeasurement> controller;
    controller = StreamController<MiScaleMeasurement>.broadcast(
      onListen: () {
        // Process scale data into measurements
        dataSubscription = readScaleData().listen((scaleData) {
          MiScaleMeasurement measurement = MiScaleMeasurement.processData(
            _activeMeasurements[scaleData.deviceId], scaleData,
          );
          if (measurement != null &&
              measurement.stage != MiScaleMeasurementStage.MEASURED)
            _activeMeasurements[scaleData.deviceId] = measurement;
          else
            _activeMeasurements.remove(scaleData.deviceId);
          if (measurement != null) controller.add(measurement);
        });
      },
      onCancel: () {
        dataSubscription?.cancel();
        cleanUpSubscription?.cancel();
        _activeMeasurements.clear();
        controller.close();
      },
    );
    return controller.stream;
  }

  /// Starts a scan for compatible devices
  ///
  /// Found devices are returned as a [MiScaleDevice] instance.
  /// The scan will automatically stop after the set [duration].
  /// To stop the scan prematurely, cancel the returned stream.
  Stream<MiScaleDevice> discoverDevices(
      {Duration duration = const Duration(seconds: 5)}) {
    StreamSubscription scanSubscription;
    StreamController<MiScaleDevice> controller;
    List<String> foundDeviceIds = [];
    controller = StreamController<MiScaleDevice>.broadcast(
      onListen: () async {
        scanSubscription = _ble.scanForDevices(
            withServices: [BODY_COMPOSITION_SERVICE],
            scanMode: ScanMode.lowLatency).listen((device) {
          // Determine the device type
          MiScaleDevice scaleDevice = MiScaleDevice.from(device);
          // If no device type found, stop
          if (scaleDevice == null) return;
          // If we already found it, stop
          if (foundDeviceIds.contains(scaleDevice.id)) return;
          // Add it to the list of found devices
          foundDeviceIds.add(scaleDevice.id);
          // Emit data
          controller.add(scaleDevice);
        });
        await Future.delayed(duration);
        scanSubscription?.cancel();
        if (!controller.isClosed) controller.close();
      },
      onCancel: () {
        scanSubscription?.cancel();
        controller.close();
        foundDeviceIds.clear();
      },
    );
    return controller.stream;
  }

  /// Listens for any incoming scale data
  ///
  /// The returned stream emits a [MiScaleData] for each received advertisement packet.
  /// Unless you need access to the parsed advertisement data directly, It is preferable to use [takeMeasurements] instead.
  Stream<MiScaleData> readScaleData() {
    StreamSubscription scanSubscription;
    StreamController<MiScaleData> controller;
    controller = StreamController<MiScaleData>.broadcast(
      onListen: () {
        scanSubscription = _ble.scanForDevices(
            withServices: [BODY_COMPOSITION_SERVICE],
            scanMode: ScanMode.lowLatency).listen((device) {
          MiScaleDevice scaleDevice = MiScaleDevice.from(device);
          // Stop if it's not a known scale device 
          if (scaleDevice == null) return;
          // Parse scale data
          MiScaleData data = scaleDevice.parseScaleData(
            device.serviceData.values.first,
          );
          if (data == null) return;
          // Emit data
          controller.add(data);
        });
      },
      onCancel: () {
        scanSubscription?.cancel();
        controller.close();
      },
    );
    return controller.stream;
  }
}
