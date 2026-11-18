import 'package:material_ui/material_ui.dart';

import '../auth/auth_controller.dart';
import '../auth/models.dart';
import '../data/field_store.dart';
import '../data/sync_service.dart';

/// Hands the store, sync and sign-in state to every screen, including ones
/// pushed on top of the main tabs.
class FieldScope extends InheritedWidget {
  const FieldScope({
    super.key,
    required this.store,
    required this.sync,
    required this.auth,
    required super.child,
  });

  final FieldStore store;
  final SyncService sync;
  final AuthController auth;

  /// The signed-in user. Only valid on screens shown while signed in.
  Profile get profile => (auth.state as AuthSignedIn).profile;

  static FieldScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FieldScope>()!;

  @override
  bool updateShouldNotify(FieldScope oldWidget) =>
      store != oldWidget.store ||
      sync != oldWidget.sync ||
      auth != oldWidget.auth;
}
