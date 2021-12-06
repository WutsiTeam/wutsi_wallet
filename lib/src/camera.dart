import 'package:camera/camera.dart';
import 'package:sdui/sdui.dart';

Future<int> initCamera() async {
  sduiCameras = await availableCameras();
  return sduiCameras.length;
}
