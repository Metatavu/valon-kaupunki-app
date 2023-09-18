import "dart:io";

import "package:device_info_plus/device_info_plus.dart";

/// Returns a unique identifier for the device. Used to enforce coupon constraints (one time use).
Future<String> getUniqueDeviceId() async {
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.identifierForVendor!;
  } else if (Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.fingerprint;
  }

  throw AssertionError("Unsupported platform");
}
