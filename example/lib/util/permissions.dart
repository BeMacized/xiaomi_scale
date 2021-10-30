import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> checkPermission() async {
  if (Platform.isIOS) return true;
  final androidInfo = await DeviceInfoPlugin().androidInfo;
  if ((androidInfo.version.sdkInt ?? 0) >= 31) {
    var status = await Permission.bluetoothScan.status;
    if (status.isDenied) {
      status = await Permission.bluetoothScan.request();
    }
    return status.isGranted;
  }
  var status = await Permission.location.status;
  if (status.isDenied) {
    status = await Permission.location.request();
  }
  return status.isGranted;
}
