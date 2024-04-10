// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mappls_gl/mappls_gl.dart';
import 'package:mapmyindia/bloc/routing/routing_events.dart';
import 'package:mapmyindia/bloc/routing/routing_states.dart';

class RoutingBloc extends Bloc<RoutingEvent, RoutingState> {
  MapplsMapController? mapController;
  RoutingBloc(
    this.mapController,
  ) : super(RoutingInitial()) {
    on<SearchLocationEvent>(searchNearByLocation);
    on<PointsSelectedEvent>(
        (event, emit) => pointsSelected(event, emit, mapController!));
  }
}

searchNearByLocation(
    SearchLocationEvent event, Emitter<RoutingState> emit) async {
  print("searchNearByLocation");

  List<NearbyResult>? nearbyResult = [];
  await MapplsNearby(
          keyword: event.key,
          location: LatLng(event.lat, event.long),
          radius: 1000)
      .callNearby()
      .then((value) {
    value!.suggestedLocations?.forEach((element) {
      nearbyResult?.add(element);
    });
  });
  for (var i in nearbyResult) {
    print(i.latitude);
  }
  emit(SearchLoactionState(nearbyResult));
}

pointsSelected(PointsSelectedEvent event, Emitter<RoutingState> emit,
    MapplsMapController mapController) async {
  print("pointsSelected");
  DirectionResponse? directionResponse = await MapplsDirection(
          origin: event.points[0], destination: event.points[1])
      .callDirection();
  print(directionResponse!.routes![0].geometry);
  List<DirectionsRoute> routes = directionResponse.routes!;
  List<List<LatLng>> geometry = [];

  for (var route in routes) {
    List<List<num>> points = decodePolyline(route.geometry!);
    List<LatLng> latLngs = [];
    for (var i in points) {
      latLngs.add(LatLng(i[0].toDouble(), i[1].toDouble()));
    }
    geometry.add(latLngs);
  }
  print(geometry.length);

  await mapController.addFill(FillOptions(
    geometry: geometry,
    fillColor: "#3bb2d0",
  ));
}
