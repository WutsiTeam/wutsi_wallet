import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sdui/sdui.dart';

Future<int> initCamera() async {
  bool granted = await _requestCameraPermission();
  if (granted) {
    sduiCameras = await availableCameras();
    return sduiCameras.length;
  } else {
    return 0;
  }
}

Future<bool> _requestCameraPermission() async {
  try {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      return await Permission.camera.request().isGranted;
    } else {
      return true;
    }
  } catch (e) {
    return true;
  }
}
