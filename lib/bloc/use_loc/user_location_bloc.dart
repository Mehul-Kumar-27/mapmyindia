import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapmyindia/bloc/use_loc/user_location_event.dart';
import 'package:mapmyindia/bloc/use_loc/user_location_states.dart';
import 'package:location/location.dart';
import 'package:mappls_gl/mappls_gl.dart';

class UserLocationBloc extends Bloc<UserLocationEvenets, UserLocationStates> {
  UserLocationBloc() : super(UserLocationInitial()) {
    on<InitUserLocation>(getUserLocation);
  }
}

Future<void> getUserLocation(
    UserLocationEvenets event, Emitter<UserLocationStates> emitter) async {
  emitter(UserLocationLoading());
  Location location = Location();
  bool serviceEnabled;
  PermissionStatus permissionGranted;
  LocationData locationData;
  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      emitter(UserLocationLoadedState(null));
    }
  }

  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return;
    }
  }

  locationData = await location.getLocation();
  emitter(UserLocationLoadedState(locationData));
}

Future userSearchingForLocation(UserIsSearchingForLocation event,
    Emitter<UserLocationStates> emitter) async {
  List<NearbyResult> ?nearbyResult = [];
  MapplsNearby(
          keyword: event.key,
          location: LatLng(event.lat, event.long),
          radius: 1000)
      .callNearby()
      .then((value) {
    nearbyResult = value?.suggestedLocations;
  });

  emitter(UserSearchResultState(nearbyResult));
}
