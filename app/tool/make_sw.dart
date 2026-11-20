// Writes build/web/sw.js from tool/sw_template.js and the build's
// precache_manifest.json (made by `flutter build web --web-content-hash`).
//
//   dart run tool/make_sw.dart build/web
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

void main(List<String> args) {
  final out = Directory(args.isEmpty ? 'build/web' : args.first);
  final manifestFile = File('${out.path}/precache_manifest.json');
  final manifestBytes = manifestFile.readAsBytesSync();
  final manifest = jsonDecode(utf8.decode(manifestBytes)) as Map<String, dynamic>;
  final urls = [for (final e in manifest['entries'] as List) (e as Map)['url'] as String];

  // Everything the app needs to start, minus the drawing engines (only the
  // one this browser uses is cached) and the licence text (rarely opened).
  final core = [
    for (final u in urls)
      if (!u.startsWith('canvaskit/') &&
          !u.startsWith('assets/NOTICES') &&
          !u.endsWith('.map') &&
          u != 'sw.js' &&
          u != 'flutter_service_worker.js')
        u,
  ];
  List<String> engine(String dir) => [
    for (final u in urls)
      if (u == '${dir}canvaskit.js' || u == '${dir}canvaskit.wasm') u,
  ];
  final version = sha1.convert(manifestBytes).toString().substring(0, 12);

  final template = File('tool/sw_template.js').readAsStringSync();
  final sw = template
      .replaceAll('__VERSION__', version)
      .replaceAll('__CORE__', jsonEncode(core))
      .replaceAll('__ENGINE_CHROMIUM__', jsonEncode(engine('canvaskit/chromium/')))
      .replaceAll('__ENGINE_FULL__', jsonEncode(engine('canvaskit/')));
  File('${out.path}/sw.js').writeAsStringSync(sw);
  stdout.writeln('sw.js $version: ${core.length} core files, engines '
      '${engine('canvaskit/chromium/').length}+${engine('canvaskit/').length}');
}
