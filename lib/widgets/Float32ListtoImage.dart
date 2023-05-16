// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';

// class Float32ListToImage extends StatefulWidget {
//   final List float32List;

//   const Float32ListToImage({Key? key, required this.float32List})
//       : super(key: key);

//   @override
//   _Float32ListToImageState createState() => _Float32ListToImageState();
// }

// class _Float32ListToImageState extends State<Float32ListToImage> {
//   ui.Image? image;

//   @override
//   void initState() {
//     super.initState();
//     _convertFloat32ListToImage();
//   }

//   void _convertFloat32ListToImage() async {
//     int width = 200; // Set the width of the image
//     int height = 200; // Calculate the height of the image
//     print('${height}, Height Saad');
//     // Create a new canvas and draw the Float32List onto it
//     final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
//     final ui.Canvas canvas = ui.Canvas(pictureRecorder);
//     final ui.Paint paint = ui.Paint();
//     final ui.Path path = ui.Path();
//     for (int y = 0; y < height; y++) {
//       for (int x = 0; x < width; x++) {
//         int index = y * width + x;
//         if (index < widget.float32List.length) {
//           // Check if the index is within the range of the Float32List

//           double value = widget.float32List[index];
//           int grayValue = ((value + 1) * 127.5).toInt().clamp(0,
//               255); // Map the float value to a grayscale value between 0 and 255
//           paint.color = ui.Color.fromARGB(255, grayValue, grayValue,
//               grayValue); // Set paint to the grayscale value
//           double xCoord = x.toDouble();
//           double yCoord = y.toDouble();
//           if (x == 0 && y == 0) {
//             path.moveTo(xCoord, yCoord);
//           } else {
//             path.lineTo(xCoord, yCoord);
//           }
//         }
//       }
//     }
//     canvas.drawPath(path, paint);

//     // Convert the canvas to an Image
//     final ui.Image finalImage =
//         await pictureRecorder.endRecording().toImage(width, height);
//     setState(() {
//       image = finalImage;
//     });
//   }

//   Future<Uint8List> _encodePng(ui.Image image) async {
//     final ByteData? byteData =
//         await image.toByteData(format: ui.ImageByteFormat.png);
//     return byteData!.buffer.asUint8List();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (image == null) {
//       print("Blank Saad");
//       return Container(); // Return a blank container until the image has been loaded
//     }

//     return FutureBuilder<Uint8List>(
//       future: _encodePng(image!),
//       builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
//         if (snapshot.hasData) {
//           return Image.memory(
//               snapshot.data!, width: 200, height: 200,); // Return the image as a Flutter widget
//         } else {
//           print("Blank Saad 2");

//           return Container(); // Return a blank container until the image has been encoded
//         }
//       },
//     );
//   }
// }
