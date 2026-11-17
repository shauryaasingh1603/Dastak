import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';

/// The app is Hindi-only for field users.
const appLocale = Locale('hi');

/// Delegates for the app's own strings and for the framework's built-in ones
/// (text-field menus, dialogs, date formats). The Material and Cupertino
/// delegates must come from their own packages: the generated
/// `AppLocalizations.localizationsDelegates` list still points at the older
/// ones, which the Material widgets no longer find.
const appLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
];
