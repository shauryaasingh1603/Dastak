import 'package:dastak/src/location.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';

import 'support/fake_geolocator.dart';

void main() {
  late FakeGeolocator gps;

  setUp(() => GeolocatorPlatform.instance = gps = FakeGeolocator());

  group('locationAccess', () {
    test('precise permission with location on is granted', () async {
      expect(await locationAccess(), LocationAccess.granted);
    });

    test('location switched off is reported first', () async {
      gps.serviceOn = false;
      expect(await locationAccess(ask: true), LocationAccess.serviceOff);
      expect(gps.prompts, 0);
    });

    test('not yet allowed: asks only when told to', () async {
      gps
        ..permission = LocationPermission.denied
        ..answer = LocationPermission.whileInUse;
      expect(await locationAccess(), LocationAccess.denied);
      expect(gps.prompts, 0);
      expect(await locationAccess(ask: true), LocationAccess.granted);
      expect(gps.prompts, 1);
    });

    test('"don\'t ask again" needs the phone settings', () async {
      gps.permission = LocationPermission.deniedForever;
      expect(await locationAccess(ask: true), LocationAccess.blocked);
      expect(gps.prompts, 0);
    });

    test('approximate only is not enough; asking offers the upgrade', () async {
      gps.accuracyStatus = LocationAccuracyStatus.reduced;
      expect(await locationAccess(), LocationAccess.approximate);
      expect(await locationAccess(ask: true), LocationAccess.approximate);
      expect(gps.prompts, 1);
    });
  });

  group('takePreciseFix', () {
    test('asks for a fresh, best-accuracy fix with a 10 s limit', () async {
      final fix = await takePreciseFix();
      expect(fix.lat, 25.7612);
      expect(fix.accuracy, 8);
      expect(fix.flag, isNull);
      final settings = gps.fixRequests.single!;
      expect(settings.accuracy, LocationAccuracy.best);
      expect(settings.timeLimit, const Duration(seconds: 10));
    });

    test('a rough fix is kept and flagged', () async {
      gps.accuracy = 240;
      final fix = await takePreciseFix();
      expect(fix.hasPosition, isTrue);
      expect(fix.flag, 'GPS_INACCURATE');
    });

    test('no fix in time is flagged as a timeout, not as GPS off', () async {
      gps.timesOut = true;
      final fix = await takePreciseFix();
      expect(fix.hasPosition, isFalse);
      expect(fix.flag, 'GPS_TIMEOUT');
    });
  });

  group('locationAccess in a browser', () {
    test('a granted site permission needs no reading', () async {
      expect(await locationAccess(web: true), LocationAccess.granted);
      expect(gps.fixRequests, isEmpty);
    });

    test(
      '"blocked" from the browser is not trusted until a reading fails',
      () async {
        gps.permission = LocationPermission.deniedForever;
        expect(await locationAccess(web: true), LocationAccess.denied);
        // The person allowed it after all: the reading works.
        expect(
          await locationAccess(ask: true, web: true),
          LocationAccess.granted,
        );
        expect(gps.fixRequests, hasLength(1));
      },
    );

    test('allowed but no fix yet still lets the volunteer work', () async {
      gps
        ..permission = LocationPermission.denied
        ..timesOut = true;
      expect(
        await locationAccess(ask: true, web: true),
        LocationAccess.granted,
      );
    });

    test('a real refusal is reported as blocked', () async {
      gps
        ..permission = LocationPermission.denied
        ..error = const PermissionDeniedException('denied');
      expect(
        await locationAccess(ask: true, web: true),
        LocationAccess.blocked,
      );
    });

    test('position unavailable means the phone location is off', () async {
      gps
        ..permission = LocationPermission.denied
        ..error = const PositionUpdateException('unavailable');
      expect(
        await locationAccess(ask: true, web: true),
        LocationAccess.serviceOff,
      );
    });
  });
}
