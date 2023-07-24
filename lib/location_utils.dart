import "package:latlong2/latlong.dart";

class LocationUtils {
  LocationUtils._();

  /// By default, returns kilometers. Adjust [multiplier] to get different magnitudes
  static double distanceBetween(LatLng point, LatLng another,
      [double multiplier = 0.001]) {
    final meters = const Distance().as(LengthUnit.Meter, point, another);
    return meters * multiplier;
  }

  static String formatDistance(LatLng point, LatLng another) {
    final distance = distanceBetween(point, another);
    if (distance >= 1) {
      return "${distance.toStringAsFixed(1)} km";
    } else {
      return "${(distance * 1000).toInt()} m";
    }
  }
}
