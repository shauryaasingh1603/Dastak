import 'dart:async';

import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// A phone's location stack, scripted for tests.
class FakeGeolocator extends GeolocatorPlatform
    with MockPlatformInterfaceMixin {
  bool serviceOn = true;
  LocationPermission permission = LocationPermission.whileInUse;

  /// What the system prompt answers; null keeps [permission] unchanged.
  LocationPermission? answer;
  LocationAccuracyStatus accuracyStatus = LocationAccuracyStatus.precise;
  double accuracy = 8;
  bool timesOut = false;

  int prompts = 0;
  final fixRequests = <LocationSettings?>[];

  @override
  Future<bool> isLocationServiceEnabled() async => serviceOn;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<LocationPermission> requestPermission() async {
    prompts++;
    if (answer != null) permission = answer!;
    return permission;
  }

  @override
  Future<LocationAccuracyStatus> getLocationAccuracy() async => accuracyStatus;

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    fixRequests.add(locationSettings);
    if (timesOut) throw TimeoutException('no fix');
    return Position(
      latitude: 25.7612,
      longitude: 82.8431,
      timestamp: DateTime.now(),
      accuracy: accuracy,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;
}
