import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late List cameras;
  late int selectedCameraIndex;
  late String imgPath;
  late CameraController cameraController;


  Future initCamera(CameraDescription cameraDescription) async {
    cameraController = CameraController(cameraDescription, ResolutionPreset.max);
    cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  /// Display camera preview
  Widget cameraPreview() {
    if (!cameraController.value.isInitialized) {
      return const Text(
        'LOADING...',
        style: TextStyle(
            color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
      );
    }

    return AspectRatio(
      aspectRatio: cameraController.value.aspectRatio,
      child: CameraPreview(cameraController),
    );
  }

  Widget cameraToggle() {
    if (cameras.isEmpty) {
      return const Spacer();
    }

    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
            onPressed: () {
              onSwitchCamera();
            },
            icon: Icon(
              getCameraLensIcons(lensDirection),
              color: Colors.white,
              size: 24,
            ),
            label: Text(
              lensDirection.toString().substring(lensDirection.toString().indexOf('.') + 1).toUpperCase(),
              style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            )),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    availableCameras().then((value) {
      cameras = value;
      if(cameras.isNotEmpty){
        setState(() {
          selectedCameraIndex = 0;
        });
        initCamera(cameras[selectedCameraIndex]).then((value) {

        });
      } else {
        print('No camera available');
      }
    }).catchError((e){
      print('Error : ${e.code}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 11,
            child: cameraPreview()
          ),
          Expanded(
            flex: 2,
            child: Container(
              height: 120,
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  cameraToggle(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  getCameraLensIcons(lensDirection) {
    switch (lensDirection) {
      case CameraLensDirection.back:
        return CupertinoIcons.switch_camera;
      case CameraLensDirection.front:
        return CupertinoIcons.switch_camera_solid;
      case CameraLensDirection.external:
        return CupertinoIcons.photo_camera;
      default:
        return Icons.device_unknown;
    }
  }

  onSwitchCamera() {
    selectedCameraIndex =
    selectedCameraIndex < cameras.length - 1 ? selectedCameraIndex + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    initCamera(selectedCamera);
  }

  showCameraException(e) {
    String errorText = 'Error ${e.code} \nError message: ${e.description}';
  }
}