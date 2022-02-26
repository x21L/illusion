import 'package:camera_deep_ar/camera_deep_ar.dart';
import 'package:flutter/material.dart';
import 'package:illusion/filters.dart';

class ChooseFilter {
  final CameraDeepArController deepArController;
  final CameraMode cameraMode;
  ChooseFilter(this.cameraMode, this.deepArController);

  Widget getMaskListView() {
    final Map<String, String> filters = {};
    filters.addAll(Filters.masks);
    filters.addAll(Filters.effects);
    filters.addAll(Filters.filters);

    print(filters);

    return AlertDialog(
      title: const Text('Choose your filter 😎'),
      backgroundColor: Colors.white.withOpacity(.3),
      content: SizedBox(
          height: 300.0, // Change as per your requirement
          width: 300.0, // Change as per your requirement
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: filters.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: ((context, index) => InkWell(
                onTap: () {
                  deepArController.switchEffect(
                      cameraMode, filters.values.elementAt(index));
                },
                child: Container(
                  height: 50,
                  color: Colors.cyanAccent.withOpacity(.3),
                  child: Center(child: Text(filters.keys.elementAt(index))),
                ))),
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
          )),
    );
  }
}
