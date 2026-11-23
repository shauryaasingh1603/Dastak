import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase/supabase.dart';

import 'field_store.dart';

/// The server calls sync needs. Split out so the sync can be tested offline.
abstract class SyncApi {
  /// Sends up to 50 outbox items; returns one result per item, in order.
  Future<List<({bool ok, String? code, String? messageHi})>> push(
    List<Map<String, dynamic>> items,
    DateTime deviceNow,
  );

  /// Everything the user may see, as one JSON document.
  Future<Map<String, dynamic>> pull();

  /// Puts a form's face photo in storage. False if the server refused it
  /// (e.g. the form was rejected); network trouble throws.
  Future<bool> uploadPhoto(String formId, Uint8List jpeg);
}

/// The server could not be reached, or did not answer properly.
class SyncNetworkException implements Exception {
  const SyncNetworkException([this.cause]);
  final Object? cause;
}

/// The server refused this phone: deactivated, or signed in elsewhere.
class SyncAccessException implements Exception {
  const SyncAccessException();
}

class SupabaseSyncApi implements SyncApi {
  SupabaseSyncApi(this._client);

  final SupabaseClient _client;

  @override
  Future<List<({bool ok, String? code, String? messageHi})>> push(
    List<Map<String, dynamic>> items,
    DateTime deviceNow,
  ) async {
    final response = await _call(
      () => _client.rpc(
        'sync_push',
        params: {
          'p_items': items,
          'p_device_now': deviceNow.toUtc().toIso8601String(),
        },
      ),
    );
    final results = (response as Map)['results'] as List;
    return [
      for (final r in results.cast<Map>())
        (
          ok: r['ok'] == true,
          code: r['code'] as String?,
          messageHi: r['message_hi'] as String?,
        ),
    ];
  }

  @override
  Future<Map<String, dynamic>> pull() async {
    final snapshot = Map<String, dynamic>.from(
      await _call(() => _client.rpc('sync_pull')) as Map,
    );
    // Polling station names, for the booth cards.
    final parts = [
      for (final b in (snapshot['booths'] as List).cast<Map>()) b['part_no'],
    ];
    if (parts.isNotEmpty) {
      final stations = await _call(
        () => _client
            .from('booths')
            .select('part_no, polling_station_hi')
            .inFilter('part_no', parts),
      );
      final byPart = {
        for (final s in (stations as List).cast<Map>())
          s['part_no']: s['polling_station_hi'],
      };
      snapshot['booths'] = [
        for (final b in (snapshot['booths'] as List).cast<Map>())
          {...b, 'station_hi': byPart[b['part_no']] ?? b['name_hi']},
      ];
    }
    return snapshot;
  }

  @override
  Future<bool> uploadPhoto(String formId, Uint8List jpeg) async {
    try {
      await _client.storage
          .from('form-photos')
          .uploadBinary(
            '$formId.jpg',
            jpeg,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );
      return true;
    } on StorageException catch (e) {
      final status = int.tryParse(e.statusCode ?? '');
      if (status == null || status >= 500) throw SyncNetworkException(e);
      if (status == 401) throw const SyncAccessException();
      return false;
    } catch (e) {
      throw SyncNetworkException(e);
    }
  }

  Future<dynamic> _call(Future<dynamic> Function() request) async {
    try {
      return await request();
    } on PostgrestException catch (e) {
      if (e.code == '42501' || e.code == 'PGRST301' || e.code == 'PGRST303') {
        throw const SyncAccessException();
      }
      throw SyncNetworkException(e);
    } on AuthException {
      throw const SyncAccessException();
    } catch (e) {
      throw SyncNetworkException(e);
    }
  }
}

enum SyncProblem { none, offline, server }

/// Sends the outbox and refreshes the local copy: on start, after every local
/// change, every 15 minutes, and when the volunteer taps "अभी सिंक करें".
class SyncService extends ChangeNotifier {
  SyncService({
    required this.api,
    required this.store,
    required this.onAccessLost,
    this.interval = const Duration(minutes: 15),
  });

  final SyncApi api;
  final FieldStore store;

  /// Called when the server refuses this phone.
  final Future<void> Function() onAccessLost;
  final Duration interval;

  String? _userId;
  Timer? _timer;
  bool _running = false;
  bool _again = false;

  bool get running => _running;

  SyncProblem _problem = SyncProblem.none;
  SyncProblem get problem => _problem;

  void start(String userId) {
    _userId = userId;
    store.onLocalChange = () => unawaited(syncNow());
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => unawaited(syncNow()));
    unawaited(syncNow());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _userId = null;
    store.onLocalChange = null;
  }

  /// Runs one sync. A call made while one is running queues one more run.
  Future<void> syncNow() async {
    final userId = _userId;
    if (userId == null) return;
    if (_running) {
      _again = true;
      return;
    }
    _running = true;
    notifyListeners();
    try {
      do {
        _again = false;
        await _pushAll();
        if (await _uploadPhotos()) await _pushAll();
        await store.applySnapshot(await api.pull(), userId: userId);
        _problem = SyncProblem.none;
      } while (_again && _userId != null);
    } on SyncAccessException {
      _problem = SyncProblem.none;
      stop();
      await onAccessLost();
    } on SyncNetworkException catch (e) {
      _problem = e.cause is PostgrestException
          ? SyncProblem.server
          : SyncProblem.offline;
    } finally {
      _running = false;
      notifyListeners();
    }
  }

  Future<void> _pushAll() async {
    while (true) {
      final batch = await store.pendingBatch();
      if (batch.isEmpty) return;
      final results = await api.push([
        for (final item in batch) item.toPushItem(),
      ], DateTime.now());
      await store.applyPushResults(batch, results);
      if (batch.length < 50) return;
    }
  }

  /// Uploads face photos for forms the server has; true if any went up.
  Future<bool> _uploadPhotos() async {
    var any = false;
    for (final photo in await store.photosToUpload()) {
      if (await api.uploadPhoto(photo.formId, photo.bytes)) {
        await store.markPhotoUploaded(photo.formId);
        any = true;
      }
    }
    return any;
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
