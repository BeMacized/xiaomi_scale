import 'dart:typed_data';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../mi_scale_data.dart';
import 'mi_scale_device_v2.dart';

abstract class MiScaleDevice {
  final DiscoveredDevice _device;

  /// The id of the discovered device
  String get id => _device.id;

  /// The name of the discovered device
  String get name => _device.name;

  /// The signal strength of the device when it was first discovered
  int get rssi => _device.rssi;

  MiScaleDevice(this._device);

  /// Parse the raw advertisement data to obtain a [MiScaleData] instance
  MiScaleData parseScaleData(Uint8List data);

  /// Constructs an instance of an extending [MiScaleDevice] class.
  ///
  /// Returns `null` if [device] has no matching class for its device type.
  static MiScaleDevice from(DiscoveredDevice device) {
    if (MiScaleDeviceV2.matchesDeviceType(device)) return MiScaleDeviceV2(device);
    return null;
  }
}
