import 'dart:typed_data';

import 'package:flutter_reactive_ble/src/model/discovered_device.dart';

import '../../xiaomi_scale.dart';
import '../mi-scale-device.dart';
import '../mi-scale-unit.dart';

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
    return device.name == 'MIBFS' &&
        device.serviceData.length == 1 &&
        device.serviceData.values.first.length == 13;
  }

  static MiScaleData _parseScaleData(String deviceId, Uint8List data) {
    if (data.length != 13) return null;
    // Prepare data
    ByteData byteData = data.buffer.asByteData();
    // Parse flags
    bool measurementComplete = data[1] & (0x01 << 1) != 0;
    bool weightStabilized = data[1] & (0x01 << 5) != 0;
    bool weightRemoved = data[1] & (0x01 << 7) != 0;
    MiScaleUnit unit = (data[0] & 0x01 != 0) ? MiScaleUnit.LBS : MiScaleUnit.KG;
    // Parse date
    int year = byteData.getUint16(2, Endian.little);
    int month = byteData.getUint8(4);
    int day = byteData.getUint8(5);
    int hour = byteData.getUint8(6);
    int minute = byteData.getUint8(7);
    int seconds = byteData.getUint8(8);
    DateTime measurementTime =
        DateTime.utc(year, month, day, hour, minute, seconds);
    // Parse weight
    double weight = byteData.getUint16(11, Endian.little).toDouble();
    if (unit == MiScaleUnit.LBS)
      weight /= 100;
    else if (unit == MiScaleUnit.KG) weight /= 200;
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
