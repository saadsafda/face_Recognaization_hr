// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_collection_literals, prefer_const_constructors, prefer_final_fields

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sowaanerp_hr/models/gps_location.dart';
import 'package:sowaanerp_hr/responsive/responsive_flutter.dart';
import 'package:sowaanerp_hr/theme.dart';
import 'package:sowaanerp_hr/utils/app_colors.dart';
import 'package:sowaanerp_hr/utils/shared_pref.dart';
import 'package:sowaanerp_hr/utils/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationsScreen extends StatefulWidget {
  const LocationsScreen({Key? key}) : super(key: key);

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  static const LatLng _center = LatLng(24.8601426, 67.0563251);
  List<LatLng> latlonList = [];
  final Utils _utils = Utils();
  final SharedPref _prefs = SharedPref();
  final List<GpsLocationModel> _locations = [];
  late GoogleMapController _controller;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  CameraPosition initialPosition = CameraPosition(
    target: _center,
    zoom: 15,
  );
  double raduis = 0.0;
  LatLng _lastMapPosition = _center;
  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _prefs.readObject(_prefs.prefLocation).then((value) => getLocation(value));
  }

  getLocation(value) async {
    if (value != null) {
      setState(() {
        value.forEach((i) {
          _locations.add(GpsLocationModel.fromJson(i));
        });
      });
      await _onAddMarkerButtonPressed();
    }
  }

  Future<void> _onAddMarkerButtonPressed() async {
    setState(() {
      _locations.forEach((element) {
        _lastMapPosition = LatLng(
            double.parse(element.location_gps!.split(',')[0]),
            double.parse(element.location_gps!.split(',')[1]));
        _markers.add(
          Marker(
            // This marker id can be anything that uniquely identifies each marker.
            markerId: MarkerId(_lastMapPosition.toString()),
            position: _lastMapPosition,
            infoWindow: InfoWindow(
              title: element.location_name.toString(),
              snippet: element.location_gps.toString(),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
          ),
        );
        _circles.add(
          Circle(
            circleId: CircleId(_lastMapPosition.toString()),
            center: _lastMapPosition,
            radius: element.allowed_radius!,
            strokeColor: AppColors.primary,
            strokeWidth: 2,
            fillColor: AppColors.primaryLight.withOpacity(0.3),
          ),
        );
        latlonList.add(LatLng(double.parse(element.location_gps!.split(',')[0]),
            double.parse(element.location_gps!.split(',')[1])));

        initialPosition = CameraPosition(
          target: _lastMapPosition,
          zoom: 15,
        );
      });
    });
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void _onMapCreated(GoogleMapController controller) async {
    _controller = controller;
    _controller.moveCamera(CameraUpdate.newLatLngBounds(
      MapUtils.boundsFromLatLngList(latlonList),
      4.0,
    ));

    var centerPoint = computeCentroid(latlonList);
    var zoom = await _controller.getZoomLevel();
    updateLocation(centerPoint.latitude, centerPoint.longitude, zoom - 2);
  }

  updateLocation(double latitude, double longitude, double zoom) async {
    _controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(latitude, longitude),
        zoom: zoom,
      ),
    ));
  }

  LatLng computeCentroid(Iterable<LatLng> points) {
    double latitude = 0;
    double longitude = 0;
    int n = points.length;

    for (LatLng point in points) {
      latitude += point.latitude;
      longitude += point.longitude;
    }

    return LatLng(latitude / n, longitude / n);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: AppColors.textWhiteGrey,
            appBar: PreferredSize(
              child: AppBar(
                primary: false,
                toolbarHeight: 100,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColors.primary),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: Text("Locations",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                      fontSize: 20,
                    )),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                ],
                backgroundColor: AppColors.textWhiteGrey,
                bottom: TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.light_grey,
                  tabs: [
                    const Tab(
                      child: Text(
                        "List",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Tab(
                      child: Text(
                        "Map",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              preferredSize: const Size.fromHeight(100),
            ),
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // first tab bar view widget
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _locations.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                          border: Border(
                            left: BorderSide(
                              color: AppColors.primary,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _locations[index].location_name.toString(),
                                    style: heading6.copyWith(
                                        color: AppColors.grey),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'GPS: ' +
                                        _locations[index]
                                            .location_gps
                                            .toString(),
                                    style: heading6.copyWith(
                                        color: AppColors.light_grey,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // second tab bar view widget
                Stack(
                  children: <Widget>[
                    GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: initialPosition,
                      mapType: _currentMapType,
                      markers: _markers,
                      onCameraMove: _onCameraMove,
                      circles: _circles,
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}

class MapUtils {
  static LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
        northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }
}
