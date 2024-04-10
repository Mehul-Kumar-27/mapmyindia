import 'package:mappls_gl/mappls_gl.dart';

class UserLocationEvenets {}

class InitUserLocation extends UserLocationEvenets {}

class UserIsSearchingForLocation extends UserLocationEvenets {
  final String key;
  final MapplsMapController mapController;
  final double lat;
  final double long;
  UserIsSearchingForLocation(this.key, this.mapController, this.lat, this.long);
}
