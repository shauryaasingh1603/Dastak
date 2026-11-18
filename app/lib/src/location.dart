import 'package:geolocator/geolocator.dart';

class LocationFix {
  const LocationFix({this.lat, this.lng, this.accuracy, this.flag});

  final double? lat;
  final double? lng;
  final double? accuracy;

  /// GPS_OFF, GPS_DENIED or GPS_INACCURATE; null for a good fix.
  final String? flag;

  bool get hasPosition => lat != null;
}

/// One GPS fix, taken when a visit form opens. Never blocks saving: a missing
/// or rough fix is recorded as a flag (R5). No background tracking.
Future<LocationFix> takeFix({
  Duration timeout = const Duration(seconds: 10),
}) async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const LocationFix(flag: 'GPS_OFF');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return const LocationFix(flag: 'GPS_DENIED');
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: timeout,
      ),
    );
    return LocationFix(
      lat: position.latitude,
      lng: position.longitude,
      accuracy: position.accuracy,
      flag: position.accuracy > 100 ? 'GPS_INACCURATE' : null,
    );
  } catch (_) {
    return const LocationFix(flag: 'GPS_OFF');
  }
}
