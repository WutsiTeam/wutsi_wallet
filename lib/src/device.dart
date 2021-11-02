import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class Device {
  final String _preferenceName = 'duid';

  Future<String> id() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString(_preferenceName);
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = const Uuid().v1();
      prefs.setString(_preferenceName, deviceId);
    }
    return deviceId;
  }
}
