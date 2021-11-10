import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class Device {
  static const String _preferenceName = 'com.wutsi.device_id';
  final String id;

  Device(this.id);

  static Future<Device> get() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString(_preferenceName);
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = const Uuid().v1();
      prefs.setString(_preferenceName, deviceId);
    }
    return Device(deviceId);
  }
}
