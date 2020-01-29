import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';

class MiniMl {
  static const MethodChannel _channel =
      const MethodChannel('plugins.flutter.io/mini_ml');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

class VisionObject {
  final Map<dynamic, dynamic> _data;
  final String trackingID;
  final Rect bounds;
  final double confidence;
  final String category;

  VisionObject._(this._data)
      : trackingID = _data['trackingID'],
        bounds = Rect.fromLTRB(_data['rect_left'], _data['rect_top'],
            _data['rect_right'], _data['rect_bottom']),
        confidence = _data['confidence'],
        category = _data['category'];
}

class FirebaseVisionObjectDetector {
  static const MethodChannel _channel =
  const MethodChannel('plugins.flutter.io/mini_ml');

  static FirebaseVisionObjectDetector instance =
  new FirebaseVisionObjectDetector._();

  FirebaseVisionObjectDetector._() {}

  Future<List<VisionObject>> detectFromBinary(Uint8List binary) async {
    try {
      List<dynamic> objects = await _channel.invokeMethod(
          "FirebaseVisionObjectDetector#detectFromBinary", {'binary': binary});
      List<VisionObject> ret = [];
      objects?.forEach((dynamic item) {
        print("item : ${item}");
        final VisionObject obj = new VisionObject._(item);
        ret.add(obj);
      });
      return ret;
    } catch (e) {
      print(
          "Error on FirebaseVisionObjectDetector#detectFromBinary : ${e.toString()}");
    }
    return null;
  }
}

class VisionLabel {
  final Map<dynamic, dynamic> _data;
  final String entityID;
  final double confidence;
  final String label;

  VisionLabel._(this._data)
      : entityID = _data['entityID'],
        confidence = _data['confidence'],
        label = _data['label'];
}

class FirebaseVisionLabelDetector {
  static const MethodChannel _channel =
  const MethodChannel('plugins.flutter.io/mini_ml');

  static FirebaseVisionLabelDetector instance =
  new FirebaseVisionLabelDetector._();

  FirebaseVisionLabelDetector._() {}

  Future<List<VisionLabel>> detectFromBinary(Uint8List binary, bool cloud) async {
    try {
      List<dynamic> labels = await _channel.invokeMethod(
          "FirebaseVisionLabelDetector#detectFromBinary", {'binary': binary, 'cloud':cloud});
      List<VisionLabel> ret = [];
      labels?.forEach((dynamic item) {
        print("item : ${item}");
        final VisionLabel label = new VisionLabel._(item);
        ret.add(label);
      });
      return ret;
    } catch (e) {
      print(
          "Error on FirebaseVisionLabelDetector#detectFromBinary : ${e.toString()}");
    }
    return null;
  }


}
