import 'package:flutter/material.dart';
import 'package:flutter_uber_map/DataHandler/appData.dart';
import 'package:flutter_uber_map/MapScreen.dart';
import 'package:flutter_uber_map/UberMapView.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  var scaffoldState = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => AppData(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Uber Maps',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home:
              // MapScreen1(),
              UberMapView(),
        ));
  }
}
