import 'package:mappls_gl/mappls_gl.dart';

class RoutingState{}

class RoutingInitial extends RoutingState {}

class SearchLoactionState extends RoutingState {
  final List<NearbyResult>? nearbyResult;
  SearchLoactionState(this.nearbyResult);
}

class PointsSelectedState extends RoutingState {
  final List<LatLng> points;
  PointsSelectedState(this.points);
}