import 'dart:typed_data';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../mi_scale_data.dart';
import '../mi_scale_unit.dart';
import 'mi_scale_device.dart';

class MiScaleDeviceV2 extends MiScaleDevice {
  MiScaleDeviceV2(DiscoveredDevice device)
      : assert(matchesDeviceType(device)),
        super(device);

  @override
  MiScaleData parseScaleData(Uint8List data) {
    return MiScaleDeviceV2._parseScaleData(id, data);
  }

  /// Determine whether this class matches the device type of the given device
  static bool matchesDeviceType(DiscoveredDevice device) {
    return device.name == 'MIBFS' && device.serviceData.length == 1 && device.serviceData.values.first.length == 13;
  }

  static MiScaleData _parseScaleData(String deviceId, Uint8List data) {
    if (data.length != 13) return null;
    // Prepare data
    final byteData = data.buffer.asByteData();
    // Parse flags
    final measurementComplete = data[1] & (0x01 << 1) != 0;
    final weightStabilized = data[1] & (0x01 << 5) != 0;
    final weightRemoved = data[1] & (0x01 << 7) != 0;
    final unit = (data[0] & 0x01 != 0) ? MiScaleUnit.LBS : MiScaleUnit.KG;
    // Parse date
    final year = byteData.getUint16(2, Endian.little);
    final month = byteData.getUint8(4);
    final day = byteData.getUint8(5);
    final hour = byteData.getUint8(6);
    final minute = byteData.getUint8(7);
    final seconds = byteData.getUint8(8);
    final measurementTime = DateTime.utc(year, month, day, hour, minute, seconds);
    // Parse weight
    var weight = byteData.getUint16(11, Endian.little).toDouble();
    if (unit == MiScaleUnit.LBS) {
      weight /= 100;
    } else if (unit == MiScaleUnit.KG) {
      weight /= 200;
    }
    // Return new scale data
    return MiScaleData(
      deviceId: deviceId,
      measurementComplete: measurementComplete,
      weightStabilized: weightStabilized,
      weightRemoved: weightRemoved,
      unit: unit,
      dateTime: measurementTime,
      weight: weight,
    );
  }
}
