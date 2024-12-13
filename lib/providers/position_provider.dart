import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

// Uses https://pub.dev/packages/geocoding to convert gps coordinates to a human readable address
import 'package:geocoding/geocoding.dart';

// Creates a provider for the status of current location
// Used to get the current location of the device
// Stores the city and country of the current location for usage in prompting gemini
class PositionProvider extends ChangeNotifier {
  // latitude of location
  double latitude = 0.0;
  // longitude of location
  double longitude = 0.0;
  // wether the position is known or not
  bool positionKnown = false;

  // String to store city/county name
  String city = '';
  String country = '';

  // PositionProvider() {
  //   init();
  // }

  // init() async {
  //   // get gps coords
  //   await updatePosition();
  //   // get position
  //   //await _determinePosition();
  //   print('city, country: ' + city + ' ' + country);
  // }

  // Updates the current position and notifies the listeners of this provider
  Future<void> updatePosition() async {
    try {
      final Position positionResult = await _determinePosition();
      latitude = positionResult.latitude;
      longitude = positionResult.longitude;
      // Call to get city/country name from coords
      final Placemark placemark = await getPlacemarks(latitude, longitude);
      // Set local vars, if placemark is null, set to empty string
      city = placemark.locality ?? '';
      country = placemark.country ?? '';

      positionKnown = true;
      notifyListeners();
    } catch (e) {
      positionKnown = false;
      // For debugging, uncomment if Gps or city/country name is not working
      //print(e);
      notifyListeners();
    }
  }

  // Determine the current position of the device
  // When the location services are not enabled or permissions
  // are denied the `Future` will return an error
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<Placemark> getPlacemarks(double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    // Debugging
    //print(placemarks);
    //print((placemarks[0].name ?? '') + (placemarks[0].street ?? ''));

    return placemarks[0];
  }
}
