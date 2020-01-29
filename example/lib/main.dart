import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mini_ml/mini_ml.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File _file;
  List<VisionObject> _foundObjects = <VisionObject>[];
  List<VisionLabel> _onDeviceLabels = <VisionLabel>[];
  List<VisionLabel> _cloudLabels = <VisionLabel>[];

  Rect _savedRect;
  Size _imageSize;
  int buildno = 0;

  FirebaseVisionObjectDetector objectDetector =
      FirebaseVisionObjectDetector.instance;
  FirebaseVisionLabelDetector labelDetector =
      FirebaseVisionLabelDetector.instance;

  @override
  void initState() {
    super.initState();
    print('initState ran');
  }

  @override
  Widget build(BuildContext context) {
    buildno++;
    print('Build no $buildno');
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('mini_ml example app'),
          ),
          body: _file == null
              ? Center(
                  child: Text(
                      'Hold the mobile vertical (portrait orientation)\nThen press the button to taka a picture and analyze it.'),
                )
              : Stack(fit: StackFit.expand, children: <Widget>[
                  Image.file(_file),
                  CustomPaint(painter: RectPainter(_savedRect, _imageSize)),
                  ListView.builder(
                      itemCount: _onDeviceLabels.length,
                      itemBuilder: (BuildContext ctxt, int index) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _onDeviceLabels[index].label,
                              style:
                                  TextStyle(fontSize: 25, color: Colors.white),
                              textAlign: TextAlign.left,
                            ),
                          )),
                  ListView.builder(
                      itemCount: _cloudLabels.length,
                      itemBuilder: (BuildContext ctxt, int index) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _cloudLabels[index].label,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white),
                              textAlign: TextAlign.right,
                            ),
                          )),
                ]),
          floatingActionButton: new FloatingActionButton(
            onPressed: () async {
              _file = await ImagePicker.pickImage(source: ImageSource.camera);
              _imageSize = await _getImageSize(Image.file(_file));
              print('_imageSize $_imageSize');
              Uint8List byteList = _file.readAsBytesSync();
              _onDeviceLabels =
                  await labelDetector.detectFromBinary(byteList, false);
              _cloudLabels = [];
              _foundObjects = await objectDetector.detectFromBinary(byteList);
              print('Number of objects found: ${_foundObjects.length}');
              if (_foundObjects.length > 0)
                _savedRect = _foundObjects[0].bounds;
              else
                _savedRect = null;
              setState(() {});
              _cloudLabels =
                  await labelDetector.detectFromBinary(byteList, true);
              setState(() {});
            },
            child: new Icon(Icons.camera),
          )),
    );
  }

  Future<Size> _getImageSize(Image image) {
    Completer<Size> completer = new Completer<Size>();
    image.image.resolve(new ImageConfiguration()).addListener(
        ImageStreamListener((ImageInfo info, bool _) => completer.complete(
            Size(info.image.width.toDouble(), info.image.height.toDouble()))));
    return completer.future;
  }
}

class RectPainter extends CustomPainter {
  Rect rect;
  Size imageSize;
  RectPainter(this.rect, this.imageSize);
  @override
  void paint(Canvas canvas, Size size) {
    // print('Canvas size $size');
    if (rect != null) {
      final paint = Paint();
      paint.color = Colors.yellow;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2.0;

      final _heightRatio = imageSize.width / size.width;
      final _widthRatio = imageSize.height / size.height;
      // print('ratio w $_widthRatio h $_heightRatio');

      final rect1 = Rect.fromLTRB(
          rect.left / _widthRatio,
          rect.top / _heightRatio,
          rect.right / _widthRatio,
          rect.bottom / _heightRatio);
      canvas.drawRect(rect1, paint);
    }
  }

  @override
  bool shouldRepaint(RectPainter oldDelegate) => oldDelegate.rect != rect;
}
