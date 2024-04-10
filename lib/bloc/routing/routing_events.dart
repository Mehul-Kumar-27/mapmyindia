import 'package:mappls_gl/mappls_gl.dart';

class RoutingEvent{}


class SearchLocationEvent extends RoutingEvent {
  final String key;
  final double lat;
  final double long;
  SearchLocationEvent(this.key, this.lat, this.long);
}

class PointsSelectedEvent extends RoutingEvent {
  final List<LatLng> points;
  PointsSelectedEvent(this.points);
}