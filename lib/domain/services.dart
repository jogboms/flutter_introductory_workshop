import 'package:camera/camera.dart';

class CameraService {
  CameraService._(this.cameras);

  final List<CameraDescription> cameras;

  static CameraService get instance => _instance;
  static late CameraService _instance;

  static Future<void> initialize() async => _instance = CameraService._(await availableCameras());
}
