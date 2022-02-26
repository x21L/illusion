import 'dart:async';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';

class CameraWidget extends StatefulWidget {
  const CameraWidget({Key? key}) : super(key: key);

  @override
  CameraAppState createState() => CameraAppState();
}

class CameraAppState extends State<CameraWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double scale = 1;

    return Scaffold(
      body: (Center(
          child: Transform.scale(
        scale: scale,
        child: const Text('camera view'),
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
                  // chooseFilter(context, poses);
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
            Timer(const Duration(seconds: 10), _launchURL);
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  _launchURL() async {
    await FlutterWebBrowser.openWebPage(
        url: "https://github.com/lukaswais-dev/illusion");
  }
}
