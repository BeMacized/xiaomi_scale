import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

Future<bool> checkPermission() async {
  if (Platform.isIOS) return true;
  var status = await Permission.location.status;
  if (status.isUndetermined || status.isDenied) {
    status = await Permission.location.request();
  }
  return status.isGranted;
}
