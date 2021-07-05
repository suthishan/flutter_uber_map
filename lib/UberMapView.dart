import 'dart:async';
import 'dart:convert';
import 'dart:math';

// import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_uber_map/DataHandler/appData.dart';
import 'package:flutter_uber_map/models/address.dart';
import 'package:flutter_uber_map/models/directDetails.dart';
import 'package:flutter_uber_map/widgets/progressDialog.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class UberMapView extends StatefulWidget {
  // final GlobalKey<ScaffoldState> scaffoldState;

  // UberMapView(this.scaffoldState);
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

  Completer<GoogleMapController> _controllerGoogleMap = Completer();

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};

  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 0;

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';
  // late final Dio _dio;

  String _startAddress = '';
  String _destinationAddress = '';
  String? _placeDistance;
  // late Directions _info;

  Set<Marker> markers = {};

  late PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  late LatLng _lastMapPosition;

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPos = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        new CameraPosition(target: latLngPosition, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  List<Polyline> _polyLine = [];

  GlobalKey<ScaffoldState> scaffoldkey = new GlobalKey<ScaffoldState>();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(12.9558463, 80.2432831),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    // scaffoldSate = widget.scaffoldState;
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
    // required Icon prefixIcon,
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
          // prefixIcon: prefixIcon,
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

  Future<DirecttionDetails> getRouteCoordinates(LatLng l1, LatLng l2) async {
    var pickUpLaLng = l1;
    var dropOffLapLng = l2;
    print(pickUpLaLng);
    print(dropOffLapLng);
    //  var details = await AssistantMethods.obtainDirectionDetails(
    //     pickUpLaLng, dropOffLapLng);
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=AIzaSyCnzEjpN8svPol7UhuEf-3XBQt4kC-dkOA";
    print(url);
    var details = await http.get(Uri.parse(url));
    // print(response.body);
    Map values = jsonDecode(details.body);
    // ProjectLog.logIt("TAG", "Predictions", values.toString());
    print(values["routes"][0]["overview_polyline"]["points"]);
    DirecttionDetails directtionDetails = DirecttionDetails();

    directtionDetails.encodedPoints =
        values["routes"][0]["overview_polyline"]["points"];

    directtionDetails.distanceText =
        values["routes"][0]["legs"][0]["distance"]["text"];
    directtionDetails.distanceValue =
        values["routes"][0]["legs"][0]["distance"]["value"];

    // directtionDetails.durationText =
    //     values["routes"][0]["legs"][0]["duration"]["text"];
    // directtionDetails.durationValue =
    //     values["routes"][0]["legs"][0]["duration"]["text"];

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPointsResult =
        polylinePoints.decodePolyline(details.toString());

    pLineCoordinates.clear();
    if (decodedPointsResult.isNotEmpty) {
      decodedPointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates.add(LatLng(l1.latitude, l2.longitude));
      });
    }

    return directtionDetails;

    // return values["routes"][0]["overview_polyline"]["points"];
  }

  // Create the polylines for showing the route between two places
  _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    // print(startLatitude);
    // print(startLongitude);
    // print(destinationLatitude);
    // print(destinationLongitude);
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyCnzEjpN8svPol7UhuEf-3XBQt4kC-dkOA", // Google Maps API Key
        PointLatLng(startLatitude, startLongitude),
        PointLatLng(destinationLatitude, destinationLongitude),
        travelMode: TravelMode.driving,
        wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]);
    // );
    print("result");
    print(result.points);

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: [
          LatLng(12.988827, 77.472091),
          LatLng(12.980821, 77.470815),
          LatLng(12.969406, 77.471301)
        ],
        width: 3,
        patterns: [PatternItem.dot, PatternItem.gap(10)]);
    polylines[id] = polyline;

    // var LOCATION_A = PointLatLng(startLatitude, startLongitude);
    // var LOCATION_B = PointLatLng(destinationLatitude, destinationLongitude);

    // _polyLine.add(Polyline(
    //   polylineId: PolylineId("route1"),
    //   color: Colors.blue,
    //   patterns: [PatternItem.dash(20.0), PatternItem.gap(10)],
    //   width: 3,
    //   points: [
    //     LOCATION_A,
    //     LOCATION_B,
    //   ],
    // ));
  }

  // Method for calculating the distance between two places
  Future<bool> _calculateDistance() async {
    try {
      // Retrieving placemarks from addresses
      List<Location> startPlacemark = await locationFromAddress(_startAddress);
      print("startPlacemark");
      print(startPlacemark);
      List<Location> destinationPlacemark =
          await locationFromAddress(_destinationAddress);
      print("destinationPlacemark");
      print(destinationPlacemark);

      // Use the retrieved coordinates of the current position,
      // instead of the address if the start position is user's
      // current position, as it results in better accuracy.
      double startLatitude = _startAddress == _currentAddress
          ? currentPos.latitude
          : startPlacemark[0].latitude;

      print(startLatitude);

      double startLongitude = _startAddress == _currentAddress
          ? currentPos.longitude
          : startPlacemark[0].longitude;
      // print(startLongitude);

      double destinationLatitude = destinationPlacemark[0].latitude;
      // print(destinationLatitude);
      double destinationLongitude = destinationPlacemark[0].longitude;
      // print(destinationLongitude);

      String startCoordinatesString = '($startLatitude, $startLongitude)';
      String destinationCoordinatesString =
          '($destinationLatitude, $destinationLongitude)';

      // Start Location Marker
      Marker startMarker = Marker(
        markerId: MarkerId(startCoordinatesString),
        position: LatLng(startLatitude, startLongitude),
        infoWindow: InfoWindow(
          title: 'Start $startCoordinatesString',
          snippet: _startAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      // Destination Location Marker
      Marker destinationMarker = Marker(
        markerId: MarkerId(destinationCoordinatesString),
        position: LatLng(destinationLatitude, destinationLongitude),
        infoWindow: InfoWindow(
          title: 'Destination $destinationCoordinatesString',
          snippet: _destinationAddress,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      // Adding the markers to the list
      markers.add(startMarker);
      markers.add(destinationMarker);
      getRouteCoordinates(LatLng(destinationLatitude, destinationLongitude),
          LatLng(startLatitude, startLongitude));
      // getPlaceDirection();

      print(
        'START COORDINATES: ($startLatitude, $startLongitude)',
      );
      print(
        'DESTINATION COORDINATES: ($destinationLatitude, $destinationLongitude)',
      );

      // Calculating to check that the position relative
      // to the frame, and pan & zoom the camera accordingly.
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

      // Accommodate the two locations within the
      // camera view of the map
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          100.0,
        ),
      );

      // Calculating the distance between the start and the end positions
      // with a straight path, without considering any route
      // double distanceInMeters = await Geolocator.bearingBetween(
      //   startLatitude,
      //   startLongitude,
      //   destinationLatitude,
      //   destinationLongitude,
      // );

      double distanceInMeters = await Geolocator.distanceBetween(
        startLatitude,
        startLongitude,
        destinationLatitude,
        destinationLongitude,
      );
      print(distanceInMeters);

      // final directions = await getDirections(
      //     origin: startMarker.position,
      //     destination: destinationMarker.position);
      // setState(() => _info = directions);

      await _createPolylines(startLatitude, startLongitude, destinationLatitude,
          destinationLongitude);

      double totalDistance = 0.0;

      // Calculating the total distance by adding the distance
      // between small segments
      for (int i = 0; i < polylineCoordinates.length - 1; i++) {
        print(polylineCoordinates);
        totalDistance += _coordinateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude,
        );
      }

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

  Future<void> getPlaceDirection() async {
    var initialPos = Provider.of<AppData>(context, listen: false).picUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;
    print(initialPos);
    print(finalPos);

    var pickUpLaLng = LatLng(initialPos!.latitude!, initialPos.longitute!);
    var dropOffLapLng = LatLng(finalPos!.latitude!, finalPos.longitute!);
    print(pickUpLaLng);
    print(dropOffLapLng);

    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Please Wait....",
      ),
    );

    var details = await getRouteCoordinates(pickUpLaLng, dropOffLapLng);

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPointsResult =
        polylinePoints.decodePolyline(details.encodedPoints!);

    pLineCoordinates.clear();
    if (decodedPointsResult.isNotEmpty) {
      decodedPointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pickUpLaLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId("polylineId"),
        color: Colors.pink,
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polylineSet.add(polyline);
    });
    LatLngBounds latLngBounds;
    if (pickUpLaLng.latitude > dropOffLapLng.latitude &&
        pickUpLaLng.longitude > dropOffLapLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLapLng, northeast: pickUpLaLng);
    } else if (pickUpLaLng.longitude > dropOffLapLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLaLng.latitude, dropOffLapLng.longitude),
          northeast: LatLng(dropOffLapLng.latitude, pickUpLaLng.longitude));
    } else if (pickUpLaLng.latitude > dropOffLapLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLapLng.latitude, pickUpLaLng.longitude),
          northeast: LatLng(pickUpLaLng.latitude, dropOffLapLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLaLng, northeast: dropOffLapLng);
    }

    mapController.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));
  }

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
              polylines:
                  // {
                  //   // ignore: unnecessary_null_comparison
                  //   if (_info != null)
                  //     Polyline(
                  //       polylineId: const PolylineId('overview_polyline'),
                  //       color: Colors.red,
                  //       width: 5,
                  //       points: _info.polylinePoints
                  //           .map((e) => LatLng(e.latitude, e.longitude))
                  //           .toList(),
                  //     ),
                  // },
                  Set<Polyline>.of(polylines.values),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              // onMapCreated: (GoogleMapController controller) {
              //   _controllerGoogleMap.complete(controller);
              //   mapController = controller;

              //   setState(() {
              //     bottomPaddingOfMap = 300.0;
              //   });
              //   locatePosition();
              // },
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

                                _calculateDistance().then((isCalculated) {
                                  if (isCalculated) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Distance Calculated Sucessfully'),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Error Calculating Distance'),
                                      ),
                                    );
                                  }
                                });
                              }
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Show Route'.toUpperCase(),
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
            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                  child: ClipOval(
                    child: Material(
                      color: Colors.orange.shade100, // button color
                      child: InkWell(
                        splashColor: Colors.orange, // inkwell color
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.my_location),
                        ),
                        onTap: () {
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                  currentPos.latitude,
                                  currentPos.longitude,
                                ),
                                zoom: 18.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<DirecttionDetails> obtainDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=AIzaSyCnzEjpN8svPol7UhuEf-3XBQt4kC-dkOA";
    // String directionUrl="https://maps.googleapis.com/maps/api/directions/json?origin=Toronto&destination=Montreal&key=$mapKey";
    // String url =
    //     "https://maps.googleapis.com/maps/api/directions/json?origin=${l1.latitude},${l1.longitude}&destination=${l2.latitude},${l2.longitude}&key=AIzaSyCnzEjpN8svPol7UhuEf-3XBQt4kC-dkOA";
    print(directionUrl);
    var details = await http.get(Uri.parse(directionUrl));
    Map values = jsonDecode(details.body);

    // var res = await RequestAssistant.getRequest(directionUrl);

    // if (res == "failed") {
    //   return null;
    // }

    DirecttionDetails directtionDetails = DirecttionDetails();

    directtionDetails.encodedPoints =
        values["routes"][0]["overview_polyline"]["points"];

    directtionDetails.distanceText =
        values["routes"][0]["legs"][0]["distance"]["text"];
    directtionDetails.distanceValue =
        values["routes"][0]["legs"][0]["distance"]["value"];

    directtionDetails.durationText =
        values["routes"][0]["legs"][0]["duration"]["value"];
    directtionDetails.durationValue =
        values["routes"][0]["legs"][0]["duration"]["value"];

    return directtionDetails;
  }

  // Future<Directions> getDirections({
  //   required LatLng origin,
  //   required LatLng destination,
  // }) async {
  //   final response = await _dio.get(
  //     _baseUrl,
  //     queryParameters: {
  //       'origin': '${origin.latitude},${origin.longitude}',
  //       'destination': '${destination.latitude},${destination.longitude}',
  //       'key': "AIzaSyBlEEDsJoLqcZDnnQXc2gxj5WUjs-K9qFA",
  //     },
  //   );

  //   // Check if response is successful
  //   if (response.statusCode == 200) {
  //     return Directions.fromMap(response.data);
  //   }
  //   return _info;
  // }
}
