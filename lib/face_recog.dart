import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui; // import the dart:ui library
import 'package:dio/dio.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sowaanerp_hr/utils/app_colors.dart';
import 'package:sowaanerp_hr/utils/detector_painters.dart';
import 'package:sowaanerp_hr/utils/face_utils.dart';
import 'package:camera/camera.dart';
// import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:sowaanerp_hr/utils/shared_pref.dart';
import 'package:image/image.dart' as imglib;
import 'package:sowaanerp_hr/utils/utils.dart';
// import 'package:sowaanerp_hr/widgets/Float32ListtoImage.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:quiver/collection.dart';
import 'package:flutter/services.dart';

import 'models/employee.dart';
import 'networking/api_helpers.dart';
import 'networking/dio_client.dart';

class MyFaceRecog extends StatefulWidget {
  bool? addButtons;
  MyFaceRecog({Key? key, this.addButtons}) : super(key: key);

  @override
  MyFaceRecogState createState() => MyFaceRecogState();
}

class MyFaceRecogState extends State<MyFaceRecog> {
  File? jsonFile;
  dynamic _scanResults;
  CameraController? _camera;
  var interpreter;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.front;
  dynamic data = {};
  double threshold = 1.0;
  Directory? tempDir;
  List? e1;
  List? asstsImg;
  List? networkImag;
  bool _faceFound = false;
  final TextEditingController _name = new TextEditingController();
  Utils _utils = new Utils();
  final SharedPref _pref = new SharedPref();
  Employee _employeeModel = Employee();
  Widget? imageWidget;
  late imglib.Image resizedImage;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    //Read employee info from prefs
    _pref
        .readObject(_pref.prefKeyEmployeeData)
        .then((value) => userDetails(value));
    _initializeCamera();
  }

  userDetails(value) async {
    if (value != null) {
      _employeeModel = Employee.fromJson(value);
      setState(() {});
    }
  }

  @override
  void dispose() {
    disposeCam();
    super.dispose();
  }

  disposeCam() async {
    _camera = null;
    await _camera?.stopImageStream();
    await _camera?.dispose();
  }

  Future loadModel() async {
    print("load");
    try {
      final gpuDelegateV2 = tfl.GpuDelegateV2(
        options: tfl.GpuDelegateOptionsV2(),
        // options: tfl.GpuDelegateOptionsV2(
        //   false,
        //   tfl.TfLiteGpuInferenceUsage.fastSingleAnswer,
        //   tfl.TfLiteGpuInferencePriority.minLatency,
        //   tfl.TfLiteGpuInferencePriority.auto,
        //   tfl.TfLiteGpuInferencePriority.auto,
        // ),
      );

      var interpreterOptions = tfl.InterpreterOptions().addDelegate(gpuDelegateV2);
      interpreter = await tfl.Interpreter.fromAsset('mobilefacenet.tflite');
    } on Exception {
      print('Failed to load model.');
    }
  }

  File? recognitionImage;

  void _initializeCamera() async {
    await loadModel();
    print('open camera');
    CameraDescription description = await getCamera(_direction);

    InputImageRotation rotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );
    _camera =
        CameraController(description, ResolutionPreset.low, enableAudio: false);
    await _camera!.initialize();
    await Future.delayed(Duration(milliseconds: 500));
    tempDir = await getApplicationDocumentsDirectory();
    String _embPath = tempDir!.path + '/emb.json';
    jsonFile = new File(_embPath);
    // String storageData = await _pref.readString(_pref.prefFaceData);
    if (_employeeModel.employeeFaceId != null &&
        _employeeModel.employeeFaceId != "") {
      data = await json.decode(_employeeModel.employeeFaceId.toString());
      // data = await json.decode(jsonFile!.readAsStringSync());
    }

    _camera!.startImageStream((CameraImage image) async {
      if (_camera != null) {
        print('image stream');
        if (_isDetecting) return;
        _isDetecting = true;
        String res;
        dynamic finalResult = Multimap<String, Face>();

        detect(image, _getDetectionMethod(), rotation).then(
          (dynamic result) async {
            print('${result},resultttt');
            if (result.length == 0)
              _faceFound = false;
            else
              _faceFound = true;
            Face _face;
            imglib.Image convertedImage =
                _convertCameraImage(image, _direction);
            for (_face in result) {
              double x, y, w, h;
              x = (_face.boundingBox.left - 10);
              y = (_face.boundingBox.top - 10);
              w = (_face.boundingBox.width + 10);
              h = (_face.boundingBox.height + 10);
              imglib.Image croppedImage = imglib.copyCrop(
                  convertedImage, x.round(), y.round(), w.round(), h.round());
              croppedImage = imglib.copyResizeCropSquare(croppedImage, 112);
              // int startTime = new DateTime.now().millisecondsSinceEpoch;
              var responseObj = await _recog(croppedImage);
              res = responseObj["name"];

              resizedImage = imglib.copyResize(responseObj["image"],
                  width: 200, height: 200);

              // int endTime = new DateTime.now().millisecondsSinceEpoch;
              // print("Inference took ${endTime - startTime}ms");
              // print('$res, Response data Checking');
              finalResult.add(res, _face);
              
              if (res != "NOT RECOGNIZED" && res != "NO FACE SAVED") {
                if (resizedImage != null) {
                  // final Directory appDir =
                  //     await getApplicationDocumentsDirectory();
                  // final String imagePath = '${appDir.path}/image.png';
                  // final tempDir = await getTemporaryDirectory();

                  // final File file =
                  //     await uint32ListToFile(resizedImage.data, imagePath);
                  final File file = await writeBytesToFile(
                      Uint8List.fromList(imglib.encodeJpg(resizedImage)),
                      "faceImage.png");

                  print('${file}, Resize Image File 1 Saad');
                  // final Uint8List byteData = resizedImage.getBytes();
                  // final Uint8List pngBytes = byteData.buffer.asUint8List();
                  // final File imageFile = File(imagePath);
                  // await imageFile.writeAsBytes(pngBytes);
                  print('${file.path}, Resized image file path Saad:');
                  await _camera!.stopImageStream();
                  await _camera!.dispose();
                  setState(() {
                    _camera = null;
                  });
                  Navigator.of(context).pop({'attchFaceImage': file});
                }
              }
              // if (res != "NOT RECOGNIZED" && res != "NO FACE SAVED") {
              //   await _camera!.stopImageStream();
              //   await _camera!.dispose();
              //   setState(() {
              //     _camera = null;
              //   });
              //   Navigator.of(context).pop();
              // }
            }
            setState(() {
              _scanResults = finalResult;
            });

            _isDetecting = false;
          },
        ).catchError(
          (error) {
            print("${error}error");
            _isDetecting = false;
          },
        );
      }
    });
  }

  HandleDetection _getDetectionMethod() {
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: true,

      ),
    );
    print(faceDetector.processImage);
    return faceDetector.processImage;
  }

  Widget _buildResults() {
    const Text noResultsText = const Text('');
    if (_scanResults == null ||
        _camera == null ||
        !_camera!.value.isInitialized) {
      return noResultsText;
    }
    CustomPainter painter;

    final Size imageSize = Size(
      _camera!.value.previewSize!.height,
      _camera!.value.previewSize!.width,
    );
    painter = FaceDetectorPainter(imageSize, _scanResults);
    return CustomPaint(
      painter: painter,
    );
  }

  Widget _buildImage() {
    if (_camera == null || !_camera!.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        Container(
          constraints: BoxConstraints.expand(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height),
          child: _camera == null
              ? const Center(child: null)
              : Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CameraPreview(_camera!),
                    _buildResults(),
                  ],
                ),
        ),
        // if (data["SAAD"] != null)
        //   Container(
        //     width: 200,
        //     height: 200,
        //     child: Float32ListToImage(float32List: data["SAAD"]),
        //   )
      ],
    );
  }

  void _toggleCameraDirection() async {
    if (_direction == CameraLensDirection.back) {
      _direction = CameraLensDirection.front;
    } else {
      _direction = CameraLensDirection.back;
    }
    await _camera!.stopImageStream();
    await _camera!.dispose();

    setState(() {
      _camera = null;
    });

    _initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Face recognition'),
      //   actions: <Widget>[
      //     PopupMenuButton<Choice>(
      //       onSelected: (Choice result) {
      //         if (result == Choice.delete)
      //           _resetFile();
      //         else
      //           _viewLabels();
      //       },
      //       itemBuilder: (BuildContext context) => <PopupMenuEntry<Choice>>[
      //         const PopupMenuItem<Choice>(
      //           child: Text('View Saved Faces'),
      //           value: Choice.view,
      //         ),
      //         const PopupMenuItem<Choice>(
      //           child: Text('Remove all faces'),
      //           value: Choice.delete,
      //         )
      //       ],
      //     ),
      //   ],
      // ),
      body: _buildImage(),
      floatingActionButton:
          _employeeModel.employeeFaceId == "" && widget.addButtons == true
              ? Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  FloatingActionButton(
                    backgroundColor:
                        (_faceFound) ? AppColors.primary : Colors.blueGrey,
                    child: Icon(Icons.add),
                    onPressed: () {
                      if (_faceFound) _addLabel();
                    },
                    heroTag: null,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  FloatingActionButton(
                    backgroundColor: AppColors.primary,
                    onPressed: _toggleCameraDirection,
                    heroTag: null,
                    child: _direction == CameraLensDirection.back
                        ? const Icon(Icons.camera_front)
                        : const Icon(Icons.camera_rear),
                  ),
                ])
              : Container(),
    );
  }

  imglib.Image _convertCameraImage(
      CameraImage image, CameraLensDirection _dir) {
    int width = image.width;
    int height = image.height;
    // imglib -> Image package from https://pub.dartlang.org/packages/image
    var img = imglib.Image(width, height); // Create Image buffer
    const int hexFF = 0xFF000000;
    final int uvyButtonStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
        final int index = y * width + x;
        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        img.data[index] = hexFF | (b << 16) | (g << 8) | r;
      }
    }
    var img1 = (_dir == CameraLensDirection.front)
        ? imglib.copyRotate(img, -90)
        : imglib.copyRotate(img, 90);
    return img1;
  }

  _recog(imglib.Image img) async {
    List input = await imageToByteListFloat32(img, 112, 128, 128);

    // Float32List floatList = Float32List.fromList(input as List<double>);
    // Uint8List buffer = Uint8List.view(floatList.buffer);
    // imageWidget = Image.memory(buffer);

    // print('${imageWidget}, My Image buffer');
    input = input.reshape([1, 112, 112, 3]);
    List output = List.filled(1 * 192, null, growable: false).reshape([1, 192]);
    await interpreter.run(input, output);
    output = output.reshape([192]);
    e1 = List.from(output);

    return {"name": compare(e1!).toUpperCase(), "image": img};
  }

  String compare(List currEmb) {
    if (data.length == 0) return "No Face saved";
    double minDist = 999;
    double currDist = 0.0;
    String predRes = "NOT RECOGNIZED";

    for (String label in data.keys) {
      currDist = euclideanDistance(data[label], currEmb);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        predRes = label;
      }
    }
    print('${minDist.toString() + " " + predRes}, Values checking');
    // setState(() {
    //   _camera = null;
    // });
    return predRes;
  }

  void _resetFile() {
    // data = {};
    // jsonFile!.deleteSync();
    // _pref.remove(_pref.prefFaceData);
  }

  void _viewLabels() {
    setState(() {
      _camera = null;
    });
    String name;
    var alert = new AlertDialog(
      title: new Text("Saved Faces"),
      content: new ListView.builder(
          padding: new EdgeInsets.all(2),
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            name = data.keys.elementAt(index);
            return new Column(
              children: <Widget>[
                new ListTile(
                  title: new Text(
                    name,
                    style: new TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                new Padding(
                  padding: EdgeInsets.all(2),
                ),
                new Divider(),
              ],
            );
          }),
      actions: <Widget>[
        new TextButton(
          child: Text("OK"),
          onPressed: () {
            _initializeCamera();
            Navigator.pop(context);
          },
        )
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }

  void _addLabel() {
    setState(() {
      _camera = null;
    });
    print("Adding new face");
    var alert = new AlertDialog(
      title: new Text("Add Face"),
      content: new Row(
        children: <Widget>[
          new Expanded(
            child: new TextField(
              controller: _name,
              autofocus: true,
              decoration: new InputDecoration(
                  labelText: "Name", icon: new Icon(Icons.face)),
            ),
          )
        ],
      ),
      actions: <Widget>[
        new TextButton(
            child: Text("Save"),
            onPressed: () {
              _handle(_name.text.toUpperCase());
              _name.clear();
              Navigator.pop(context);
            }),
        new TextButton(
          child: Text("Cancel"),
          onPressed: () {
            _initializeCamera();
            Navigator.pop(context);
          },
        )
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }

  void _handle(String text) async {
    data[text] = e1;
    // print("${_employeeModel.employeeFaceId}, Employee Model Face id Checking");
    if (_employeeModel.employeeFaceId == "") {
      // print("${_employeeModel.employeeFaceId}, Employee Model Face id Checking");
      // print("You can Add New Face Checking");
      var formData = FormData.fromMap({
        "name": _employeeModel.name,
        "bytesImage": json.encode(data),
      });
      Future response = APIFunction.post(
          context, _utils, ApiClient.apiAddFaceId, formData, '');
      var res = await response;
      if (res != null) {
        _employeeModel = Employee.fromJson(res.data["message"]["employee"]);

        _pref.saveObject(_pref.prefKeyEmployeeData, _employeeModel);
      }
    }
    // await _pref.saveString(_pref.prefFaceData, json.encode(data));
    jsonFile!.writeAsStringSync(json.encode(data));
    _initializeCamera();
  }
}
