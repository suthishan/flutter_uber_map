import 'dart:async';
import 'dart:math';

// import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UberMapView extends StatefulWidget {
  UberMapView({Key? key}) : super(key: key);

  @override
  _UberMapViewState createState() => _UberMapViewState();
}

class _UberMapViewState extends State<UberMapView> {
  late Position currentPos;
  late GoogleMapController mapController;
  String _currentAddress = '';
  TextEditingController destinationController = TextEditingController();
  Color darkBlue = Colors.black;
  Color grey = Colors.grey;
  GlobalKey<ScaffoldState> scaffoldSate = GlobalKey<ScaffoldState>();
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};

  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 0;

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();

  String _startAddress = '';
  String _destinationAddress = '';
  String? _placeDistance;

  Set<Marker> markers = {};

  late PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPos = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        new CameraPosition(target: latLngPosition, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(12.9558463, 80.2432831),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  //getCurrent Location of user
  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        currentPos = position;
        print('CURRENT POS: $currentPos');
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  Widget _textField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required double width,
    Widget? suffixIcon,
    required Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        focusNode: focusNode,
        decoration: new InputDecoration(
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey.shade400,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue.shade300,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }

  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          currentPos.latitude, currentPos.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        print(_currentAddress);
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyCnzEjpN8svPol7UhuEf-3XBQt4kC-dkOA", // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.transit,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      jointType: JointType.round,
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: true,
    );
    polylines[id] = polyline;
  }

  Future<bool> _calculateDistance() async {
    try {
      List<Location> startPlacemark = await locationFromAddress(_startAddress);
      List<Location> destinationPlacemark =
          await locationFromAddress(_destinationAddress);
      double startLatitude = _startAddress == _currentAddress
          ? currentPos.latitude
          : startPlacemark[0].latitude;

      print(startLatitude);

      double startLongitude = _startAddress == _currentAddress
          ? currentPos.longitude
          : startPlacemark[0].longitude;

      double destinationLatitude = destinationPlacemark[0].latitude;
      double destinationLongitude = destinationPlacemark[0].longitude;

      String startCoordinatesString = '($startLatitude, $startLongitude)';
      String destinationCoordinatesString =
          '($destinationLatitude, $destinationLongitude)';
      Marker startMarker = Marker(
        markerId: MarkerId(startCoordinatesString),
        position: LatLng(startLatitude, startLongitude),
        infoWindow: InfoWindow(
          title: 'Start $startCoordinatesString',
          snippet: _startAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );
      Marker destinationMarker = Marker(
        markerId: MarkerId(destinationCoordinatesString),
        position: LatLng(destinationLatitude, destinationLongitude),
        infoWindow: InfoWindow(
          title: 'Destination $destinationCoordinatesString',
          snippet: _destinationAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );
      markers.add(startMarker);
      markers.add(destinationMarker);
      // getPlaceDirection(startLatitude, startLongitude, destinationLatitude,
      //     destinationLongitude);
      double miny = (startLatitude <= destinationLatitude)
          ? startLatitude
          : destinationLatitude;
      double minx = (startLongitude <= destinationLongitude)
          ? startLongitude
          : destinationLongitude;
      double maxy = (startLatitude <= destinationLatitude)
          ? destinationLatitude
          : startLatitude;
      double maxx = (startLongitude <= destinationLongitude)
          ? destinationLongitude
          : startLongitude;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          100.0,
        ),
      );

      await _createPolylines(startLatitude, startLongitude, destinationLatitude,
          destinationLongitude);

      double totalDistance = 0.0;

      // Calculating the total distance by adding the distance
      // between small segments
      for (int i = 0; i < polylineCoordinates.length - 1; i++) {
        totalDistance += _coordinateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude,
        );
      }

      double distanceInMeters = await Geolocator.distanceBetween(
        startLatitude,
        startLongitude,
        destinationLatitude,
        destinationLongitude,
      );
      print(distanceInMeters);

      setState(() {
        double km = distanceInMeters / 1000;
        _placeDistance = km.toStringAsFixed(2);
        print('DISTANCE: $_placeDistance km');
      });

      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  // Future<void> getPlaceDirection(
  //     double startlat, double startlong, double deslat, double deslon) async {
  //   var pickUpLaLng = LatLng(startlat, startlong);
  //   var dropOffLapLng = LatLng(deslat, deslon);
  //   print(pickUpLaLng);
  //   print(dropOffLapLng);

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) => ProgressDialog(
  //       message: "Please Wait....",
  //     ),
  //   );

  //   var details = await getRouteCoordinates(pickUpLaLng, dropOffLapLng);

  //   Navigator.pop(context);

  //   PolylinePoints polylinePoints = PolylinePoints();
  //   List<PointLatLng> decodedPointsResult =
  //       polylinePoints.decodePolyline(details.encodedPoints!);
  //   print("decodedPointsResult");
  //   print(decodedPointsResult);

  //   pLineCoordinates.clear();
  //   if (decodedPointsResult.isNotEmpty) {
  //     decodedPointsResult.forEach((PointLatLng pointLatLng) {
  //       pLineCoordinates
  //           .add(LatLng(pickUpLaLng.latitude, pointLatLng.longitude));
  //     });
  //     double totalDistance = 0.0;
  //     for (int i = 0; i < pLineCoordinates.length - 1; i++) {
  //       // print(pLineCoordinates);
  //       totalDistance += _coordinateDistance(
  //         pLineCoordinates[i].latitude,
  //         pLineCoordinates[i].longitude,
  //         pLineCoordinates[i + 1].latitude,
  //         pLineCoordinates[i + 1].longitude,
  //       );
  //       print("totalDistance");
  //       print(totalDistance);
  //     }
  //   }

  //   polylineSet.clear();
  //   setState(() {
  //     Polyline polyline = Polyline(
  //       polylineId: PolylineId("polylineId"),
  //       color: Colors.pink,
  //       jointType: JointType.round,
  //       points: pLineCoordinates,
  //       width: 5,
  //       startCap: Cap.roundCap,
  //       endCap: Cap.roundCap,
  //       geodesic: true,
  //     );
  //     // print(polyline);
  //     polylineSet.add(polyline);
  //   });
  //   LatLngBounds latLngBounds;
  //   if (pickUpLaLng.latitude > dropOffLapLng.latitude &&
  //       pickUpLaLng.longitude > dropOffLapLng.longitude) {
  //     latLngBounds =
  //         LatLngBounds(southwest: dropOffLapLng, northeast: pickUpLaLng);
  //   } else if (pickUpLaLng.longitude > dropOffLapLng.longitude) {
  //     latLngBounds = LatLngBounds(
  //         southwest: LatLng(pickUpLaLng.latitude, dropOffLapLng.longitude),
  //         northeast: LatLng(dropOffLapLng.latitude, pickUpLaLng.longitude));
  //   } else if (pickUpLaLng.latitude > dropOffLapLng.latitude) {
  //     latLngBounds = LatLngBounds(
  //         southwest: LatLng(dropOffLapLng.latitude, pickUpLaLng.longitude),
  //         northeast: LatLng(pickUpLaLng.latitude, dropOffLapLng.longitude));
  //   } else {
  //     latLngBounds =
  //         LatLngBounds(southwest: pickUpLaLng, northeast: dropOffLapLng);
  //   }

  //   mapController.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));
  // }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      child: Scaffold(
        key: scaffoldkey,
        body: Stack(
          children: [
            GoogleMap(
              markers: Set<Marker>.from(markers),
              padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              initialCameraPosition: _kGooglePlex,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              polylines: Set<Polyline>.of(polylines.values),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: Container(
                height: 270.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      offset: Offset(0.7, 0.7),
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20.0,
                      ),
                      SizedBox(height: 10),
                      _textField(
                          label: 'Start',
                          hint: 'Choose starting point',
                          // prefixIcon: Icon(Icons.looks_one),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.my_location),
                            onPressed: () {
                              startAddressController.text = _currentAddress;
                              _startAddress = _currentAddress;
                            },
                          ),
                          controller: startAddressController,
                          focusNode: startAddressFocusNode,
                          width: width,
                          locationCallback: (String value) {
                            setState(() {
                              _startAddress = value;
                            });
                          }),
                      SizedBox(height: 10),
                      _textField(
                          label: 'Destination',
                          hint: 'Choose destination',
                          // prefixIcon: Icon(Icons.looks_two),
                          controller: destinationAddressController,
                          focusNode: desrinationAddressFocusNode,
                          width: width,
                          locationCallback: (String value) {
                            setState(() {
                              _destinationAddress = value;
                            });
                          }),
                      SizedBox(
                        height: 14.0,
                      ),
                      Visibility(
                        visible: _placeDistance == null ? false : true,
                        child: Text(
                          'DISTANCE: $_placeDistance km',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      ElevatedButton(
                        onPressed: (_startAddress != '' &&
                                _destinationAddress != '')
                            ? () async {
                                startAddressFocusNode.unfocus();
                                desrinationAddressFocusNode.unfocus();
                                setState(() {
                                  if (markers.isNotEmpty) markers.clear();
                                  if (polylines.isNotEmpty) polylines.clear();
                                  if (polylineCoordinates.isNotEmpty)
                                    polylineCoordinates.clear();
                                  _placeDistance = null;
                                });

                                _calculateDistance().then((isCalculated) {});
                              }
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Show Directions'.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
