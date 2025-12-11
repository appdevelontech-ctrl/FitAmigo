import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

extension GeolocatorExt on Geolocator {
  static Future<List<Placemark>> getAddressFromLatLng(Position position) async {
    try {
      // This correctly uses the geocoding package
      return await placemarkFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      print('Reverse geocoding failed: $e');
      return [];
    }
  }
}
