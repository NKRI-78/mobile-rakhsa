import 'package:device_info_plus/device_info_plus.dart';
import 'package:rakhsa/injection.dart';

Future<int> getAndroidVersion() async {
  final androidInfo = await locator<DeviceInfoPlugin>().androidInfo;
  return androidInfo.version.sdkInt;
}
