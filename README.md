# mini_ml

Minimal ML Kit plugin

Supports only the following ML Kit functions:
- Object detection & tracking
- Image labeling On-device
- Image labeling Cloud

## Getting Started
```
  List<VisionObject> _foundObjects = <VisionObject>[];
  List<VisionLabel> _onDeviceLabels = <VisionLabel>[];
  List<VisionLabel> _cloudLabels = <VisionLabel>[];

  FirebaseVisionObjectDetector objectDetector = FirebaseVisionObjectDetector.instance;
  FirebaseVisionLabelDetector labelDetector = FirebaseVisionLabelDetector.instance;

  _foundObjects = await objectDetector.detectFromBinary(byteList);
  _onDeviceLabels = await labelDetector.detectFromBinary(byteList, false);
  _cloudLabels = await labelDetector.detectFromBinary(byteList, true);
```
  For a complete example, see the example directory. To install the example app, first
   [add Firebase to your Flutter app](https://firebase.google.com/docs/flutter/setup?platform=android)
 ```
   cd example
   flutter build apk
   flutter install apk
```

