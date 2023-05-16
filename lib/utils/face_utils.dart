import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
// import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as imglib;
import 'package:path_provider/path_provider.dart';

typedef HandleDetection = Future<dynamic> Function(InputImage image);

enum Choice { view, delete }

Future<CameraDescription> getCamera(CameraLensDirection dir) async {
  return await availableCameras().then(
    (List<CameraDescription> cameras) => cameras.firstWhere(
      (CameraDescription camera) => camera.lensDirection == dir,
    ),
  );
}

InputImageData buildMetaData(
  CameraImage image,
  InputImageRotation rotation,
) {
  return InputImageData(
    inputImageFormat: InputImageFormat.bgra8888,
    size: Size(image.width.toDouble(), image.height.toDouble()),
    imageRotation: rotation,
    planeData: image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList(),
  );
}

Future<dynamic> detect(
  CameraImage image,
  HandleDetection handleDetection,
  InputImageRotation rotation,
) async {
  final WriteBuffer allBytes = WriteBuffer();
for (final Plane plane in image.planes) {
  allBytes.putUint8List(plane.bytes);
}
final bytes = allBytes.done().buffer.asUint8List();

final Size imageSize =
    Size(image.width.toDouble(), image.height.toDouble());
final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw) ??
        InputImageFormat.nv21;
final planeData = image.planes.map(
  (Plane plane) {
    return InputImagePlaneMetadata(
      bytesPerRow: plane.bytesPerRow,
      height: plane.height,
      width: plane.width,
    );
  },
).toList();

final inputImageData = InputImageData(
  size: imageSize,
  imageRotation: rotation,
  inputImageFormat: inputImageFormat,
  planeData: planeData,
);
  return handleDetection(
     InputImage.fromBytes(
    bytes: bytes,
    inputImageData:inputImageData
  ),
  );
}

InputImageRotation rotationIntToImageRotation(int rotation) {
  switch (rotation) {
    case 0:
      return InputImageRotation.rotation0deg;
    case 90:
      return InputImageRotation.rotation90deg;
    case 180:
      return InputImageRotation.rotation180deg;
    default:
      assert(rotation == 270);
      return InputImageRotation.rotation270deg;
  }
}

Future<ui.Image> bytesToImage(List<dynamic> bytes) async {
  final decodedBytes = base64.decode(bytes.cast<String>().join());
  final completer = Completer<ui.Image>();
  ui.decodeImageFromList(Uint8List.fromList(decodedBytes), (ui.Image img) {
    completer.complete(img);
  });
  return completer.future;
}

Future<File> writeBytesToFile(Uint8List bytes, String? fileName) async {
  final directory = await getTemporaryDirectory();
  final filePath = '${directory.path}/${fileName ?? getRandomFileName()}';
  final file = File(filePath);
  await file.writeAsBytes(bytes);
  print('File saved to $filePath');
  return file;
}

String getRandomFileName() {
  final random = Random.secure();
  final now = DateTime.now().toIso8601String().replaceAll(RegExp(r'[^\d]'), '');
  final randomString = List.generate(6, (_) => random.nextInt(9)).join('');
  return '$now-$randomString';
}

Future<File> uint32ListToFile(Uint32List data, String path) async {
  final bytes = data.buffer.asUint8List();
  final file = File(path);
  await file.writeAsBytes(bytes);
  return file;
}

Uint8List convertFloat32ListToUint8List(Float32List float32List) {
  var bytes = <int>[];
  for (var i = 0; i < float32List.length; i++) {
    bytes.addAll(float32List[i].toStringAsFixed(1).codeUnits);
  }
  return Uint8List.fromList(bytes);
}

Future<Image> convertFloat32ListToImage(
    Float32List float32List, int width, int height) async {
  var byteData = convertFloat32ListToUint8List(float32List).buffer.asByteData();
  var codec = await ui.instantiateImageCodec(byteData as Uint8List,
      targetWidth: width, targetHeight: height);
  var frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}

imageToByteListFloat32(
    imglib.Image image, int inputSize, double mean, double std) {
  var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
  var buffer = Float32List.view(convertedBytes.buffer);
  int pixelIndex = 0;
  for (var i = 0; i < inputSize; i++) {
    for (var j = 0; j < inputSize; j++) {
      var pixel = image.getPixel(j, i);
      buffer[pixelIndex++] = (imglib.getRed(pixel) - mean) / std;
      buffer[pixelIndex++] = (imglib.getGreen(pixel) - mean) / std;
      buffer[pixelIndex++] = (imglib.getBlue(pixel) - mean) / std;
    }
  }
  return convertedBytes.buffer.asFloat32List();
}

double euclideanDistance(List e1, List e2) {
  double sum = 0.0;
  for (int i = 0; i < e1.length; i++) {
    sum += pow((e1[i] - e2[i]), 2);
  }
  return sqrt(sum);
}
