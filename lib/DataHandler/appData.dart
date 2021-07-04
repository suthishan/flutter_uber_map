import 'package:flutter/material.dart';
import 'package:flutter_uber_map/models/address.dart';

class AppData extends ChangeNotifier {
  Address? picUpLocation, dropOffLocation;

  void updatePickupLocationAddress(Address pickUpAddress) {
    picUpLocation = pickUpAddress;
    notifyListeners();
  }

  void upDateDropOffLocationAddress(Address dropOffAddress) {
    dropOffLocation = dropOffAddress;
    notifyListeners();
  }
}
