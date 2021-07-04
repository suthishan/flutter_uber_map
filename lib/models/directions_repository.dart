// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_uber_map/models/address.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class DirectionsRepository {
//   static const String _baseUrl =
//       'https://maps.googleapis.com/maps/api/directions/json?';

//   final Dio _dio;

//   DirectionsRepository({Dio dio}) : _dio = dio;

//   Future<Directions> getDirections({
//     required LatLng origin,
//     required LatLng destination,
//   }) async {
//     final response = await _dio.get(
//       _baseUrl,
//       queryParameters: {
//         'origin': '${origin.latitude},${origin.longitude}',
//         'destination': '${destination.latitude},${destination.longitude}',
//         'key': "AIzaSyBlEEDsJoLqcZDnnQXc2gxj5WUjs-K9qFA",
//       },
//     );

//     // Check if response is successful
//     if (response.statusCode == 200) {
//       return Directions.fromMap(response.data);
//     }
//     // return null;
//   }
// }
