// // import 'package:flutter/material.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';

// // import 'package:flutter_polyline_points/flutter_polyline_points.dart';

// // class MapScreen extends StatefulWidget {
// //   @override
// //   _MapScreenState createState() => _MapScreenState();
// // }

// // class _MapScreenState extends State<MapScreen> {
// //   late GoogleMapController mapController;
// //   double _originLatitude = 6.5212402, _originLongitude = 3.3679965;
// //   double _destLatitude = 6.849660, _destLongitude = 3.648190;
// //   // double _originLatitude = 26.48424, _originLongitude = 50.04551;
// //   // double _destLatitude = 26.46423, _destLongitude = 50.06358;
// //   Map<MarkerId, Marker> markers = {};
// //   Map<PolylineId, Polyline> polylines = {};
// //   List<LatLng> polylineCoordinates = [];
// //   PolylinePoints polylinePoints = PolylinePoints();
// //   String googleAPiKey = "Please provide your api key";

// //   @override
// //   void initState() {
// //     super.initState();

// //     /// origin marker
// //     _addMarker(LatLng(_originLatitude, _originLongitude), "origin",
// //         BitmapDescriptor.defaultMarker);

// //     /// destination marker
// //     _addMarker(LatLng(_destLatitude, _destLongitude), "destination",
// //         BitmapDescriptor.defaultMarkerWithHue(90));
// //     _getPolyline();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return SafeArea(
// //       child: Scaffold(
// //           body: GoogleMap(
// //         initialCameraPosition: CameraPosition(
// //             target: LatLng(_originLatitude, _originLongitude), zoom: 15),
// //         myLocationEnabled: true,
// //         tiltGesturesEnabled: true,
// //         compassEnabled: true,
// //         scrollGesturesEnabled: true,
// //         zoomGesturesEnabled: true,
// //         onMapCreated: _onMapCreated,
// //         markers: Set<Marker>.of(markers.values),
// //         polylines: Set<Polyline>.of(polylines.values),
// //       )),
// //     );
// //   }

// //   void _onMapCreated(GoogleMapController controller) async {
// //     mapController = controller;
// //   }

// //   _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
// //     MarkerId markerId = MarkerId(id);
// //     Marker marker =
// //         Marker(markerId: markerId, icon: descriptor, position: position);
// //     markers[markerId] = marker;
// //   }

// //   _addPolyLine() {
// //     PolylineId id = PolylineId("poly");
// //     Polyline polyline = Polyline(
// //         polylineId: id, color: Colors.red, points: polylineCoordinates);
// //     polylines[id] = polyline;
// //     setState(() {});
// //   }

// //   _getPolyline() async {
// //     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
// //         googleAPiKey,
// //         PointLatLng(_originLatitude, _originLongitude),
// //         PointLatLng(_destLatitude, _destLongitude),
// //         travelMode: TravelMode.driving,
// //         wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]);
// //     if (result.points.isNotEmpty) {
// //       result.points.forEach((PointLatLng point) {
// //         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
// //       });
// //     }
// //     _addPolyLine();
// //   }
// // }

// // import 'package:google_maps_flutter/google_maps_flutter.dart';

// // static const LatLng _center = const LatLng(33.738045, 73.084488);
// // final Set<Marker> _markers = {};
// // final Set<Polyline>_polyline={};

// // //add your lat and lng where you wants to draw polyline
// // LatLng _lastMapPosition = _center;
// // List<LatLng> latlng = List();
// // LatLng _new = LatLng(33.738045, 73.084488);
// // LatLng _news = LatLng(33.567997728, 72.635997456);

// // latlng.add(_new);
// // latlng.add(_news);

// // //call this method on button click that will draw a polyline and markers

// // void _onAddMarkerButtonPressed() {
// //     getDistanceTime();
// //     setState(() {
// //         _markers.add(Marker(
// //             // This marker id can be anything that uniquely identifies each marker.
// //             markerId: MarkerId(_lastMapPosition.toString()),
// //             //_lastMapPosition is any coordinate which should be your default
// //             //position when map opens up
// //             position: _lastMapPosition,
// //             infoWindow: InfoWindow(
// //                 title: 'Really cool place',
// //                 snippet: '5 Star Rating',
// //             ),
// //             icon: BitmapDescriptor.defaultMarker,

// //         ));
// //         _polyline.add(Polyline(
// //             polylineId: PolylineId(_lastMapPosition.toString()),
// //             visible: true,
// //             //latlng is List<LatLng>
// //             points: latlng,
// //             color: Colors.blue,
// //         ));
// //     });

// //     //in your build widget method
// //     GoogleMap(
// //     //that needs a list<Polyline>
// //         polylines:_polyline,
// //         markers: _markers,
// //         onMapCreated: _onMapCreated,
// //         myLocationEnabled:true,
// //         onCameraMove: _onCameraMove,
// //         initialCameraPosition: CameraPosition(
// //             target: _center,
// //             zoom: 11.0,
// //         ),

// //         mapType: MapType.normal,

// //     );
// // }

// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';

// const double CAMERA_ZOOM = 12;
// const double CAMERA_TILT = 0;
// const double CAMERA_BEARING = 30;
// const LatLng SOURCE_LOCATION = LatLng(44.745883, 65.539635);

// class MapPage extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => MapPageState();
// }

// class MapPageState extends State<MapPage> {
//   Completer<GoogleMapController> _controller = Completer();
//   Set<Marker> _markers = {};
//   Set<Polyline> _polylines = {};
//   String googleAPIKey = "AIzaSyBlEEDsJoLqcZDnnQXc2gxj5WUjs-K9qFA";
//   late BitmapDescriptor sourceIcon;
//   late BitmapDescriptor destinationIcon;
//   late List<TaskModel> listofTasks;

//   @override
//   void initState() {
//     super.initState();
//     takePermissions();
//   }

//   Future<void> takePermissions() async {
//     if (await Permission.location.request().isGranted &&
//         await Permission.camera.request().isGranted) {
//       setSourceAndDestinationIcons();
//     }
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.location,
//       Permission.camera,
//     ].request();
//     print(statuses[Permission.camera]);
//   }

//   void setSourceAndDestinationIcons() async {
//     sourceIcon = await BitmapDescriptor.fromAssetImage(
//         ImageConfiguration(devicePixelRatio: 2.5), 'assets/source.png');
//     destinationIcon = await BitmapDescriptor.fromAssetImage(
//         ImageConfiguration(devicePixelRatio: 2.5), 'assets/destination.png');
//   }

//   @override
//   Widget build(BuildContext context) {
//     CameraPosition initialLocation = CameraPosition(
//         zoom: CAMERA_ZOOM,
//         bearing: CAMERA_BEARING,
//         tilt: CAMERA_TILT,
//         target: SOURCE_LOCATION);
//     return Scaffold(
//       appBar: null,
//       body: Container(
//         color: Colors.white,
//         child: Column(
//           children: [
//             Container(
//               height: 400,
//               child: GoogleMap(
//                   myLocationEnabled: true,
//                   compassEnabled: true,
//                   tiltGesturesEnabled: false,
//                   markers: _markers,
//                   polylines: _polylines,
//                   mapType: MapType.normal,
//                   initialCameraPosition: initialLocation,
//                   onMapCreated: onMapCreated),
//             ),
//             Container(
//               color: Colors.white,
//               child: ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: listofTasks.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     // onTap: () => _onTapItem(),
//                     title: Text(
//                       listofTasks != null ? listofTasks[index].name : "",
//                     ),
//                     leading: Icon(
//                       Icons.ac_unit_outlined,
//                       color: Colors.cyan.shade900,
//                     ),
//                     subtitle: Text(
//                       listofTasks != null ? listofTasks[index].address : "",
//                       style: TextStyle(color: Colors.grey, fontSize: 10),
//                     ),
//                   );
//                 },
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   void onMapCreated(GoogleMapController controller) {
//     controller.setMapStyle(Utils.mapStyles);
//     _controller.complete(controller);
//     setMapPins();
//   }

//   void setMapPins() async {
//     // source pin

//     TaskModel model = new TaskModel(
//         "1", "Polyline 1", "", 44.711048, 65.588712, 44.718929, 65.543472);
//     listofTasks.add(model);

//     TaskModel model1 = new TaskModel(
//         "2", "Polyline 2", "", 44.765871, 65.548230, 44.748915, 65.528095);
//     listofTasks.add(model1);
//     Polyline polyline;
//     if (listofTasks != null && listofTasks.length > 0) {
//       for (var one in listofTasks) {
//         try {
//           List<LatLng> polylineCoordinates = [];
//           LatLng SOURCE = LatLng(one.slatitude, one.slongitude);
//           LatLng DEST = LatLng(one.dlatitude, one.dlongitude);
//           PolylinePoints polylinePoints = PolylinePoints();

//           _markers.add(Marker(
//               markerId: MarkerId('sourcePin' + one.taskid),
//               position: SOURCE,
//               icon: sourceIcon));
//           _markers.add(Marker(
//               markerId: MarkerId('destPin' + one.taskid),
//               position: DEST,
//               icon: destinationIcon));

//           List<PointLatLng> result =
//               await polylinePoints.getRouteBetweenCoordinates(
//                   googleAPIKey,
//                   LatLng(one.slatitude, one.slongitude),
//                   LatLng(one.dlatitude, one.dlongitude));
//           print("result>>>-----    " + result.toString());
//           if (result.isNotEmpty) {
//             print("result>>>>>>>>>>    " + result.toString());
//             result.forEach((PointLatLng point) {
//               polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//             });
//           }
//           setState(() {
//             polyline = Polyline(
//                 polylineId: PolylineId("poly" + one.taskid),
//                 color: Color.fromARGB(204, 147, 70, 140),
//                 width: 6,
//                 points: polylineCoordinates);
//             _polylines.add(polyline);
//           });
//         } catch (e) {
//           print("Ex--- $e");
//         }
//       }
//     }
//   }
// }

// class Utils {
//   static String mapStyles = '''[
//   {
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#f5f5f5"
//       }
//     ]
//   },
//   {
//     "elementType": "labels.icon",
//     "stylers": [
//       {
//         "visibility": "off"
//       }
//     ]
//   },
//   {
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#616161"
//       }
//     ]
//   },
//   {
//     "elementType": "labels.text.stroke",
//     "stylers": [
//       {
//         "color": "#f5f5f5"
//       }
//     ]
//   },
//   {
//     "featureType": "administrative.land_parcel",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#bdbdbd"
//       }
//     ]
//   },
//   {
//     "featureType": "poi",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#eeeeee"
//       }
//     ]
//   },
//   {
//     "featureType": "poi",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#757575"
//       }
//     ]
//   },
//   {
//     "featureType": "poi.park",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#e5e5e5"
//       }
//     ]
//   },
//   {
//     "featureType": "poi.park",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#9e9e9e"
//       }
//     ]
//   },
//   {
//     "featureType": "road",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#ffffff"
//       }
//     ]
//   },
//   {
//     "featureType": "road.arterial",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#757575"
//       }
//     ]
//   },
//   {
//     "featureType": "road.highway",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#dadada"
//       }
//     ]
//   },
//   {
//     "featureType": "road.highway",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#616161"
//       }
//     ]
//   },
//   {
//     "featureType": "road.local",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#9e9e9e"
//       }
//     ]
//   },
//   {
//     "featureType": "transit.line",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#e5e5e5"
//       }
//     ]
//   },
//   {
//     "featureType": "transit.station",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#eeeeee"
//       }
//     ]
//   },
//   {
//     "featureType": "water",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#c9c9c9"
//       }
//     ]
//   },
//   {
//     "featureType": "water",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#9e9e9e"
//       }
//     ]
//   }
// ]''';
// }

// class TaskModel {
//   String taskid;
//   String name;
//   String address;
//   double slatitude;
//   double dlatitude;
//   double slongitude;
//   double dlongitude;

//   TaskModel(this.taskid, this.name, this.address, this.slatitude,
//       this.slongitude, this.dlatitude, this.dlongitude);
// }
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uber_map/models/address.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen1 extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen1> {
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(37.773972, -122.431297),
    zoom: 11.5,
  );

  late GoogleMapController _googleMapController;
  // String startCoordinatesString = '($startLatitude, $startLongitude)';
  // String destinationCoordinatesString =
  //     '($destinationLatitude, $destinationLongitude)';
  late Marker _origin;
  late Marker _destination;
  late Directions _info;

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Google Maps'),
        actions: [
          // if (_origin != null)
          TextButton(
            onPressed: () => _googleMapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(12.9558463, 80.2432831),
                  zoom: 14.5,
                  tilt: 50.0,
                ),
              ),
            ),
            style: TextButton.styleFrom(
              primary: Colors.green,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
            child: const Text('ORIGIN'),
          ),
          // if (_destination != null)
          TextButton(
            onPressed: () => _googleMapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: _destination.position,
                  zoom: 14.5,
                  tilt: 50.0,
                ),
              ),
            ),
            style: TextButton.styleFrom(
              primary: Colors.blue,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
            child: const Text('DEST'),
          )
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) => _googleMapController = controller,
            markers: {_origin, _destination},
            polylines: {
              if (_info != null)
                Polyline(
                  polylineId: const PolylineId('overview_polyline'),
                  color: Colors.red,
                  width: 5,
                  points: _info.polylinePoints
                      .map((e) => LatLng(e.latitude, e.longitude))
                      .toList(),
                ),
            },
            onLongPress: _addMarker,
          ),
          if (_info != null)
            Positioned(
              top: 20.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 12.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.yellowAccent,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 6.0,
                    )
                  ],
                ),
                child: Text(
                  '${_info.totalDistance}, ${_info.totalDuration}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        onPressed: () => _googleMapController.animateCamera(
          _info != null
              ? CameraUpdate.newLatLngBounds(_info.bounds, 100.0)
              : CameraUpdate.newCameraPosition(_initialCameraPosition),
        ),
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

  void _addMarker(LatLng pos) async {
    if (_origin == null || (_origin != null && _destination != null)) {
      // Origin is not set OR Origin/Destination are both set
      // Set origin
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origin'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: pos,
        );
        // Reset destination
        // _destination = null;

        // Reset info
        // _info = null;
      });
    } else {
      // Origin is already set
      // Set destination
      setState(() {
        _destination = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: pos,
        );
      });

      // Get directions
      final directions =
          await getDirections(origin: _origin.position, destination: pos);
      setState(() => _info = directions);
    }
  }

  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';
  late final Dio _dio;

  Future<Directions> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final response = await _dio.get(
      _baseUrl,
      queryParameters: {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'key': "AIzaSyBlEEDsJoLqcZDnnQXc2gxj5WUjs-K9qFA",
      },
    );

    // Check if response is successful
    if (response.statusCode == 200) {
      return Directions.fromMap(response.data);
    }
    return _info;
  }
}
