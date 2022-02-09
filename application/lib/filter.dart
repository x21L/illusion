import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

enum Filter { a, b, c }

Card _getFilterCard(final String title, final String text) {
  return Card(
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
    ListTile(
      // leading: const Icon(Icons.album),
      title: Text(title),
      subtitle: Text(text),
    ),
  ]));
}

// choose filter
Future<void> chooseFilter(BuildContext context, List<Pose> poses) async {
  switch (await showDialog<Filter>(
      context: context,
      builder: (BuildContext context) {
        if (poses.isNotEmpty) {
          return SimpleDialog(
            title: const Text('Select Filter'),
            children: <Widget>[
              SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, Filter.a);
                  },
                  child: _getFilterCard(
                      'Number of poses', 'Found ${poses.length} poses')),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, Filter.b);
                },
                child: _getFilterCard('Found the following Landmarks',
                    '${poses[0].landmarks.keys}'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, Filter.c);
                },
                child: _getFilterCard('Likelihood',
                    'First landmark key: ${poses[0].landmarks.keys.first} likelihood: ${poses[0].landmarks.entries.first.value.likelihood}'),
              ),
            ],
          );
        }
        return const SimpleDialog(
          title: Text("No poses found 😔"),
        );
      })) {
    case Filter.a:
      // Let's go.
      // ...
      break;
    case Filter.b:
      // ...
      break;
    case Filter.c:
      // ...
      break;
    case null:
      // dialog dismissed
      break;
  }
}
