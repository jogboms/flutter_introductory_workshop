import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_introductory_workshop/domain.dart';

class CameraView extends StatefulWidget {
  const CameraView({Key? key, this.onComplete}) : super(key: key);

  final ValueChanged<String>? onComplete;

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    controller = CameraController(CameraService.instance.cameras[0], ResolutionPreset.medium)
      ..initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
  }

  @override
  void dispose() {
    controller.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(controller.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    const double buttonSize = 64;
    return Material(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CameraPreview(controller),
          Positioned.fill(
            top: null,
            bottom: buttonSize / 2,
            child: MaterialButton(
              onPressed: takePicture,
              shape: const CircleBorder(),
              color: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.onPrimary,
              child: ConstrainedBox(
                constraints: BoxConstraints.tight(const Size.square(buttonSize)),
                child: const Icon(Icons.camera, size: buttonSize),
              ),
            ),
          )
        ],
      ),
    );
  }

  void onNewCameraSelected(CameraDescription description) async {
    await controller.dispose();

    controller = CameraController(description, ResolutionPreset.medium, imageFormatGroup: ImageFormatGroup.jpeg)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
        if (controller.value.hasError) {
          showMessage('Error: ${controller.value.errorDescription}');
        }
      });

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {});
      }
    } on CameraException catch (e) {
      showError(e.code, e.description);
    }
  }

  Future<void> takePicture() async {
    if (!controller.value.isInitialized) {
      showMessage('Select a camera first.');
      return;
    }
    if (controller.value.isTakingPicture) {
      return;
    }

    try {
      final XFile file = await controller.takePicture();
      if (mounted) {
        widget.onComplete?.call(file.path);
      }
    } on CameraException catch (e) {
      showError(e.code, e.description);
    }
  }

  void showError(String code, String? message) =>
      showMessage('Error: $code\n${message != null ? 'Message: $message' : ''}');

  void showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
