import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sowaanerp_hr/common/common_dialog.dart';
import 'package:sowaanerp_hr/common/common_widget.dart';
import 'package:sowaanerp_hr/models/employee.dart';
import 'package:sowaanerp_hr/networking/api_helpers.dart';
import 'package:sowaanerp_hr/networking/dio_client.dart';
// import 'package:sowaanerp_hr/networking/image_helpers.dart';
import 'package:sowaanerp_hr/responsive/responsive_flutter.dart';
import 'package:sowaanerp_hr/screens/locations_screen.dart';
import 'package:sowaanerp_hr/screens/login_screen.dart';
// import 'package:sowaanerp_hr/screens/select_photo_options_screen.dart';
import 'package:sowaanerp_hr/theme.dart';
import 'package:sowaanerp_hr/utils/app_colors.dart';
import 'package:sowaanerp_hr/utils/shared_pref.dart';
import 'package:sowaanerp_hr/utils/utils.dart';
import 'package:photo_view/photo_view.dart';
// import 'package:sowaanerp_hr/widgets/bottom_sheet.dart';
// import 'package:sowaanerp_hr/widgets/constant.dart';
import 'package:sowaanerp_hr/widgets/custom_appbar.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:sowaanerp_hr/widgets/primary_button.dart';

import '../face_recog.dart';

// final imageHelper = ImageHelper();

// ignore: must_be_immutable
class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final Utils _utils = Utils();
  SharedPref prefs = SharedPref();
  Employee _employeeModel = Employee();
  // final picker = ImagePicker();
  bool _showUploadButton = false;
  String baseURL = '';

  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";

  @override
  void initState() {
    super.initState();

    initApp();
  }

  File? _image;
  // Future _pickImage(ImageSource source) async {
  //   try {
  //     print('${source},  "source image"');
  //     final image = await ImagePicker().pickImage(source: source);
  //     if (image == null) return;
  //     File? img = File(image.path);
  //     img = await _cropImage(imageFile: img);
  //     var formdata = {
  //       "url": MultipartFile.fromFile(image.path, filename: image.name)
  //     }; // just like JS
  //     print("${image}, ${img}, formdata");
  //     // formdata.add("photos", UploadFileInfo(_image, basename(_image!.path)));
  //     setState(() {
  //       _image = img;
  //       _showUploadButton = true;
  //       Navigator.of(context).pop();
  //     });
  //   } on PlatformException catch (e) {
  //     Navigator.of(context).pop();
  //   }
  // }

  // Future<File?> _cropImage({required File imageFile}) async {
  //   var croppedImage = await ImageCropper().cropImage(
  //     sourcePath: imageFile.path,
  //   );
  //   if (croppedImage == null) return null;
  //   return File(croppedImage.path);
  // }

  // /// Get Profile Image
  // _getProfileImage(source) async {
  //   final files;
  //   if (source == 'gallery') {
  //     files = await imageHelper.pickImage(source: ImageSource.gallery);
  //   } else {
  //     files = await imageHelper.pickImage(
  //       source: ImageSource.camera,
  //       cameraDevice: CameraDevice.front,
  //     );
  //   }
  //   if (files.isNotEmpty) {
  //     final croppedFile = await imageHelper.crop(file: files.first);
  //     if (croppedFile != null) {
  //       setState(() {
  //         _image = File(croppedFile.path);
  //         _showUploadButton = true;
  //       });
  //     }
  //     Navigator.of(context).pop();
  //   }
  // }

  // /// Get from gallery
  // _getFromGallery() async {
  //   final files = await imageHelper.pickImage(source: ImageSource.gallery);
  //   if (files.isNotEmpty) {
  //     final croppedFile = await imageHelper.crop(file: files.first);
  //     if (croppedFile != null) {
  //       setState(() {
  //         _image = File(croppedFile.path);
  //         _showUploadButton = true;
  //       });
  //     }
  //   }
  // }

  // /// Get from camera
  // _getFromCamera() async {
  //   _utils.showProgressDialog(context);
  //   final files = await imageHelper.pickImage(
  //     source: ImageSource.camera,
  //     cameraDevice: CameraDevice.front,
  //   );
  //   if (files.isNotEmpty) {
  //     final croppedFile = await imageHelper.crop(file: files.first);
  //     if (croppedFile != null) {
  //       // _image = File(croppedFile.path);
  //       setState(() {
  //         _image = File(croppedFile.path);
  //       });
  //       _utils.hideProgressDialog(context);
  //     }
  //   }
  // }

  Future<void> initApp() async {
    //Read base url from prefs
    prefs.readString(prefs.prefBaseUrl).then((value) {
      setState(() {
        baseURL = value;
      });
      print('${baseURL}, BaseUrl Value');
    });

    //Read employee info from prefs
    prefs.readObject(prefs.prefKeyEmployeeData).then((value) => {
          if (value != null)
            {
              setState(() {
                _employeeModel = Employee.fromJson(value);
              })
            }
        });

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;

    setState(() {});
  }

  logout() {
    prefs.saveObject(prefs.prefKeyEmployeeData, null);
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
      builder: (context) {
        return LoginScreen(
          isLoggedIn: false,
        );
      },
    ), (route) => false);
  }

  // uploadImage() async {
  //   _utils.showProgressDialog(context);

  //   // String encodedImage = "";

  //   // Uint8List bytes = await _image!.readAsBytes();
  //   // encodedImage = base64Encode(bytes);
  //   print('${_image}, sadfsgasbad');
  //   List<MultipartFile> _files = [];
  //   _files.add(MultipartFile.fromFileSync(
  //     _image!.path,
  //     filename: _image!.path.split('/').last,
  //   ));
  //   var formData = FormData.fromMap({
  //     'file': _files.first,
  //     'is_private': 0,
  //     'folder': 'Home',
  //     'optimize': true
  //   });
  //   Future data = APIFunction.post(
  //       context, _utils, ApiClient.apiUploadImage, formData, '');
  //   var res = await data;
  //   print('${res.data['message']['file_url']}, upload image res');
  //   // var stream = new http.ByteStream(_image!.openRead());
  //   // stream.cast();
  //   // print('${stream}, image val');
  //   var file_url = res.data['message']['file_url'];
  //   await updateImage(file_url);
  // }

  // updateImage(imagePath) async {
  //   print('${_employeeModel.name}start User Image');

  //   var formData =
  //       FormData.fromMap({"name": _employeeModel.name, "image": imagePath});
  //   Future response = APIFunction.post(
  //       context, _utils, ApiClient.apiUpdateUserImage, formData, '');

  //   var res = await response;
  //   print('${res}, Response User Image');
  //   updatePrefrence(res);
  // }

  
  uploadImage() async {
    _utils.showProgressDialog(context);
    List<MultipartFile> _files = [];
    _files.add(MultipartFile.fromFileSync(
      _image!.path,
      filename: _image!.path.split('/').last,
    ));
    var formData = FormData.fromMap({
      'file': _files.first,
      'is_private': 0,
      'folder': 'Home',
      'optimize': true
    });
    Future data = APIFunction.post(
        context, _utils, ApiClient.apiUploadImage, formData, '');
    var res = await data;
    var file_url = res.data['message']['file_url'];
    await updateImage(file_url);
  }
  
  updateImage(imagePath) async {
    var formData =
        FormData.fromMap({"name": _employeeModel.name, "image": imagePath});
    Future response = APIFunction.post(
        context, _utils, ApiClient.apiUpdateUserImage, formData, '');

    var res = await response;
    print('${res}, Response User Image');
    updatePrefrence(res);
  }

  updatePrefrence(value) {
    if (value != null && value.statusCode == 200) {
      Employee employeeModel = Employee.fromJson(value.data["message"]);

      prefs.saveObject(prefs.prefKeyEmployeeData, employeeModel);
      setState(() {
        _showUploadButton = false;
      });
      _utils.hideProgressDialog(context);
      initApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.textWhiteGrey,
        appBar: const PreferredSize(
          child: CustomAppBar(
            title: "Settings",
            icon: Icons.notifications_none,
            // icon2: Icons.settings,
          ),
          preferredSize: Size.fromHeight(50),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(left: 16, right: 16, bottom: 6),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          IntrinsicHeight(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HeroPhotoViewRouteWrapper(
                                      name: '${_employeeModel.employeeName}',
                                      imageProvider: NetworkImage(
                                        _employeeModel.image != null &&
                                                _employeeModel.image!
                                                    .startsWith("https://")
                                            ? _employeeModel.image.toString()
                                            : '$baseURL${_employeeModel.image}',
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: SizedBox(
                                width: ResponsiveFlutter.of(context).scale(100),
                                height: ResponsiveFlutter.of(context)
                                    .verticalScale(100),
                                // child: Container(),
                                child: Center(
                                  child: Container(
                                    height: 200.0,
                                    width: 200.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey.shade200,
                                    ),
                                    child: Center(
                                      child: _image == null
                                          ? Hero(
                                              tag: 'someTag',
                                              child: widgetCommonProfile(
                                                imagePath: _employeeModel
                                                                .image !=
                                                            null &&
                                                        _employeeModel.image!
                                                            .startsWith(
                                                                "https://")
                                                    ? _employeeModel.image
                                                        .toString()
                                                    : '$baseURL${_employeeModel.image}',
                                                isBackGroundColorGray: false,
                                              ),
                                            )
                                          : CircleAvatar(
                                              backgroundImage:
                                                  FileImage(_image!),
                                              radius: 200.0,
                                            ),
                                      // child: _image == null
                                      //     ? const Text(
                                      //         'No image selected',
                                      //         style: TextStyle(fontSize: 20),
                                      //       )
                                      //     : CircleAvatar(
                                      //         backgroundImage: FileImage(_image!),
                                      //         radius: 200.0,
                                      //       ),
                                    ),
                                  ),
                                ),
                                // child: Hero(
                                //   tag: 'someTag',
                                //   child: widgetCommonProfile(
                                //     imagePath: _employeeModel.image != null &&
                                //             _employeeModel.image!
                                //                 .startsWith("https://")
                                //         ? _employeeModel.image.toString()
                                //         : '$baseURL${_employeeModel.image}',
                                //     isBackGroundColorGray: false,
                                //   ),
                                // ),
                              ),
                            ),
                          ),
                          if (_employeeModel.employeeFaceId == "")
                            Positioned(
                              bottom: 3,
                              right: 3,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 55,
                                  ),
                                  const SizedBox(
                                    width: 25,
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MyFaceRecog(addButtons: true,),
                                        ),
                                      );
                                      setState(() {
                                        _image = result["attchFaceImage"];
                                      });
                                      print(
                                          '${result["attchFaceImage"]}, Response Resized image file path Saad:');
                                      uploadImage();
                                      // showModalBottomSheet(
                                      //   context: context,
                                      //   isScrollControlled: true,
                                      //   backgroundColor: const Color(0x00000000),
                                      //   shape: const RoundedRectangleBorder(
                                      //       borderRadius: BorderRadius.vertical(
                                      //     top: Radius.circular(20),
                                      //   )),
                                      //   builder: (BuildContext context) {
                                      //     return Container(
                                      //       margin: const EdgeInsets.all(10),
                                      //       decoration: kBoxDecoration.copyWith(
                                      //           borderRadius:
                                      //               BorderRadius.circular(16)),
                                      //       child: SelectPhotoOptionsScreen(
                                      //         getGallery: () {
                                      //           _getProfileImage('gallery');
                                      //           // _getFromGallery();
                                      //         },
                                      //         getCamera: () {
                                      //           // _getFromCamera();
                                      //           _getProfileImage("camera");
                                      //         },
                                      //       ),
                                      //     );
                                      //   },
                                      // );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: AppColors
                                              .textPurpleColorWithOpacity,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(50))),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      _employeeModel.employeeName != null
                          ? Text(
                              '${_employeeModel.employeeName}',
                              textAlign: TextAlign.right,
                              style: heading5.copyWith(
                                  color: AppColors.primary, fontSize: 20),
                            )
                          : Container(),
                      const SizedBox(
                        height: 10,
                      ),
                      _employeeModel.designation != null
                          ? Text(
                              '${_employeeModel.designation}',
                              textAlign: TextAlign.right,
                              style: heading5.copyWith(
                                  color: AppColors.primary, fontSize: 15),
                            )
                          : Container(),
                      _employeeModel.designation != null
                          ? const SizedBox(
                              height: 10,
                            )
                          : Container(),
                      _employeeModel.department != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.apartment,
                                  color: AppColors.textGrey,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  '${_employeeModel.department}',
                                  textAlign: TextAlign.right,
                                  style: heading6.copyWith(
                                      color: AppColors.textGrey, fontSize: 14),
                                ),
                              ],
                            )
                          : Container(),
                      if (_showUploadButton)
                        const SizedBox(
                          height: 14,
                        ),
                      if (_showUploadButton)
                        PrimaryButton(
                          callback: () {
                            // uploadImage();
                            // setState(() {
                            //   _showUploadButton = false;
                            // });
                          },
                          buttonColor: AppColors.primary,
                          textValue: "Upload",
                          textColor: AppColors.white,
                        )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      title: Text(
                        'Allowed Locations',
                        style: heading6.copyWith(color: AppColors.textGrey),
                      ),
                      leading: const Icon(Icons.gps_fixed),
                      iconColor: AppColors.primary,
                      minLeadingWidth: 10,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LocationsScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: Text(
                          "$appName v$version (${buildNumber.padLeft(2, '0')})",
                          style: heading6.copyWith(color: AppColors.textGrey)),
                      leading: const Icon(Icons.info_outline),
                      iconColor: AppColors.primary,
                      minLeadingWidth: 10,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _utils.hideKeyboard(context);

            dialogConfirm(context, _utils, () {
              logout();
            }, "Are you sure to logout from the app?");
          },
          backgroundColor: AppColors.checkoutRed,
          label: const Text("Logout"),
          icon: const Icon(Icons.logout),
        ),
      ),
    );
  }
}

class HeroPhotoViewRouteWrapper extends StatelessWidget {
  const HeroPhotoViewRouteWrapper({
    Key? key,
    this.name,
    required this.imageProvider,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
  }) : super(key: key);

  final String? name;
  final ImageProvider imageProvider;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: PhotoView(
          imageProvider: imageProvider,
          backgroundDecoration: backgroundDecoration,
          minScale: minScale,
          maxScale: maxScale,
          heroAttributes: const PhotoViewHeroAttributes(tag: "someTag"),
        ),
      ),
    );
  }
}
