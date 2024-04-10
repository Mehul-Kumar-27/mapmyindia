import 'package:location/location.dart';
import 'package:mappls_gl/mappls_gl.dart';

class UserLocationStates {}

class UserLocationInitial extends UserLocationStates {}

class UserLocationLoading extends UserLocationStates {}

class UserLocationLoadedState extends UserLocationStates {
  LocationData? locationData;
  UserLocationLoadedState(this.locationData);
}

class UserSearchingForLocation extends UserLocationStates {
  final String key;
  UserSearchingForLocation(this.key);
}

class UserSearchResultState extends UserLocationStates {
  final List<NearbyResult>? nearbyResult;
  UserSearchResultState(this.nearbyResult);
}
