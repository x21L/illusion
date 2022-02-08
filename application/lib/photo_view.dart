import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:illusion/main.dart';
import 'package:illusion/pose_painter.dart';
import 'filter.dart';
import 'filter_view.dart';

class CameraWidget extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraWidget(this.cameras, {Key? key}) : super(key: key);

  @override
  CameraAppState createState() => CameraAppState();
}

class CameraAppState extends State<CameraWidget> {
  late CameraController controller;
  var showCapturedPhoto = false;
  // MLkit stuff
  PoseDetector poseDetector = GoogleMlKit.vision.poseDetector();
  bool isBusy = false;
  CustomPaint? customPaint;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[1], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    controller.dispose();
    await poseDetector.close();
  }

  @override
  Widget build(BuildContext context) {
    double scale = 1;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      var camera = controller.value;
      // fetch screen size
      final size = MediaQuery.of(context).size;

      // calculate scale depending on screen and camera ratios
      // this is actually size.aspectRatio / (1 / camera.aspectRatio)
      // because camera preview size is received as landscape
      // but we're calculating for portrait orientation
      scale = size.aspectRatio * camera.aspectRatio;
      // to prevent scaling down, invert the value
      if (scale < 1) scale = 1 / scale;
    }
    return Scaffold(
      body: (Center(
          child: Transform.scale(
        scale: scale,
        child: CameraPreview(controller),
      ))),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Hey 👋'),
                          content: const Text(
                              'Want to checkout the project on GitHub?'),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                                child: const Text('Close')),
                            TextButton(
                              onPressed: () {
                                _launchURL();
                              },
                              child: const Text('yes!'),
                            )
                          ],
                        );
                      });
                }),
            const Spacer(),
            IconButton(
                icon: const Icon(Icons.camera),
                onPressed: () async {
                  var poses = await processImage();
                  chooseFilter(context, poses);
                }),
          ],
        ),
      ),
      floatingActionButton: ArgonTimerButton(
        height: 50,
        width: MediaQuery.of(context).size.width * 0.45,
        minWidth: MediaQuery.of(context).size.width * 0.30,
        color: Colors.cyan,
        borderRadius: 5.0,
        child: const Icon(Icons.camera_alt),
        loader: (timeLeft) {
          return Text(
            "Wait | $timeLeft",
            style: const TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700),
          );
        },
        onTap: (startTimer, btnState) {
          if (btnState == ButtonState.Idle) {
            startTimer(10);
            Timer(const Duration(seconds: 10), takePicture);
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;

    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      File imageFile = File(file.path);
      // GallerySaver.saveImage(file.path);
      _safeImage(imageFile, file.path);
      return file;
    } on CameraException catch (e) {
      return null;
    }
  }

  void _safeImage(File file, String path) {
    final FilterView filterview = FilterView(file);
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Save Image'),
              content: filterview.buildImage(context),
              actions: <Widget>[
                OutlinedButton(
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.cyanAccent),
                  ),
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.cyanAccent),
                  ),
                  onPressed: () async {
                    filterview.saveImage();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            ));
  }

  Future<List<Pose>> processImage() async {
    final CameraController? cameraController = controller;

    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
    }

    try {
      XFile file = await cameraController.takePicture();
      File imageFile = File(file.path);
      InputImage inputImage = InputImage.fromFile(imageFile);

      if (isBusy) return [];
      isBusy = true;
      final poses = await poseDetector.processImage(inputImage);

      if (inputImage.inputImageData?.size != null &&
          inputImage.inputImageData?.imageRotation != null) {
        final painter = PosePainter(poses, inputImage.inputImageData!.size,
            inputImage.inputImageData!.imageRotation);
        customPaint = CustomPaint(painter: painter);
      } else {
        customPaint = null;
      }
      isBusy = false;
      if (mounted) {
        setState(() {});
      }

      return poses;
    } on CameraException catch (e) {
      log('Error occured while taking picture: $e');
    }

    return [];
  }

  _launchURL() async {
    await FlutterWebBrowser.openWebPage(
        url: "https://github.com/lukaswais-dev/illusion");
  }
}
