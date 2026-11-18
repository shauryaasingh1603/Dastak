import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

/// Whether the app may take a precise location right now.
enum LocationAccess {
  /// Precise location is allowed and the phone's location is on.
  granted,

  /// Only approximate location was allowed (Android 12+ lets people choose).
  approximate,

  /// Not allowed yet; asking again shows the system prompt.
  denied,

  /// Refused with "don't ask again": only the phone's settings can change it.
  blocked,

  /// The phone's location (GPS) is switched off.
  serviceOff,
}

/// Checks location access. With [ask], shows the system permission prompt
/// when that can still change the answer.
Future<LocationAccess> locationAccess({bool ask = false}) async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationAccess.serviceOff;
    }
    var permission = await Geolocator.checkPermission();
    if (ask && permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    switch (permission) {
      case LocationPermission.deniedForever:
        return LocationAccess.blocked;
      case LocationPermission.denied:
      case LocationPermission.unableToDetermine:
        return LocationAccess.denied;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        break;
    }
    if (!kIsWeb &&
        await Geolocator.getLocationAccuracy() ==
            LocationAccuracyStatus.reduced) {
      if (ask) {
        // On Android 12+ asking again offers to upgrade to precise.
        await Geolocator.requestPermission();
        if (await Geolocator.getLocationAccuracy() ==
            LocationAccuracyStatus.precise) {
          return LocationAccess.granted;
        }
      }
      return LocationAccess.approximate;
    }
    return LocationAccess.granted;
  } catch (_) {
    return LocationAccess.serviceOff;
  }
}

/// Opens the screen where the person can fix [access].
Future<void> openLocationFix(LocationAccess access) async {
  try {
    if (access == LocationAccess.serviceOff) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
    }
  } catch (_) {
    // Nothing more the app can do; the screen explains the steps.
  }
}

class LocationFix {
  const LocationFix({this.lat, this.lng, this.accuracy, this.flag});

  final double? lat;
  final double? lng;

  /// Radius in metres within which the true position lies.
  final double? accuracy;

  /// Recorded on the visit when the fix is missing or rough:
  /// GPS_TIMEOUT (no fix in time), GPS_INACCURATE (worse than 100 m),
  /// GPS_OFF (location unavailable). Null for a good fix.
  final String? flag;

  bool get hasPosition => lat != null;
}

/// Takes one fresh, full-accuracy fix, at the moment a visit is saved.
/// Never older than this call: cached positions are not reused. Callers
/// check [locationAccess] first. No background tracking.
Future<LocationFix> takePreciseFix({
  Duration timeout = const Duration(seconds: 10),
}) async {
  try {
    final settings = kIsWeb
        ? LocationSettings(accuracy: LocationAccuracy.best, timeLimit: timeout)
        : AndroidSettings(
            accuracy: LocationAccuracy.best,
            timeLimit: timeout,
            maxUpdateAge: Duration.zero,
          );
    final position = await Geolocator.getCurrentPosition(
      locationSettings: settings,
    );
    return LocationFix(
      lat: position.latitude,
      lng: position.longitude,
      accuracy: position.accuracy,
      flag: position.accuracy > 100 ? 'GPS_INACCURATE' : null,
    );
  } on TimeoutException {
    return const LocationFix(flag: 'GPS_TIMEOUT');
  } catch (_) {
    return const LocationFix(flag: 'GPS_OFF');
  }
}
