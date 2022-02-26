import 'dart:async';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:camera_deep_ar/camera_deep_ar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:illusion/choose_filter.dart';

import 'config.dart';
import 'filters.dart';

class DeepARCamera extends StatefulWidget {
  const DeepARCamera({Key? key}) : super(key: key);

  @override
  _DeepARCameraState createState() => _DeepARCameraState();
}

class _DeepARCameraState extends State<DeepARCamera> {
  final deepArController = CameraDeepArController(config);
  bool isRecording = false;
  CameraMode cameraMode = config.cameraMode;
  DisplayMode displayMode = config.displayMode;
  int currentEffect = 0;
  List get effectList {
    switch (cameraMode) {
      case CameraMode.mask:
        return Filters.masks.values.toList();

      case CameraMode.effect:
        return Filters.effects.values.toList();

      case CameraMode.filter:
        return Filters.filters.values.toList();

      default:
        return Filters.masks.values.toList();
    }
  }

  @override
  void initState() {
    super.initState();
    CameraDeepArController.checkPermissions();
    deepArController.setEventHandler(DeepArEventHandler(onCameraReady: (v) {
      setState(() {});
    }, onSnapPhotoCompleted: (v) {
      setState(() {});
    }, onVideoRecordingComplete: (v) {
      setState(() {});
    }, onSwitchEffect: (v) {
      setState(() {});
    }));
  }

  @override
  void dispose() {
    super.dispose();
    deepArController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double scale = 1;

    return Scaffold(
      body: (Center(
          child: Transform.scale(
        scale: scale,
        child: DeepArPreview(deepArController),
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
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return ChooseFilter(cameraMode, deepArController)
                            .getMaskListView();
                      });
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
            Timer(const Duration(seconds: 10), _takepicture);
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _takepicture() {
    deepArController.snapPhoto();
    _showTakenDialog();
  }

  Future<void> _showTakenDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Picture saved successfully 📸'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('At the desk you can print it'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _launchURL() async {
    await FlutterWebBrowser.openWebPage(
        url: "https://github.com/lukaswais-dev/illusion");
  }
}
