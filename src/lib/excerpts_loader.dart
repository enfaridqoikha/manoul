import 'package:flutter/services.dart' show rootBundle;

class ExcerptsLoader {
  Future<List<String>> load() async {
    final files = [
      'assets/excerpts/dbc_electrical.txt',
      'assets/excerpts/dbc_mechanical.txt',
      'assets/excerpts/dbc_plumbing.txt',
      'assets/excerpts/dbc_fire.txt',
    ];
    final out = <String>[];
    for (final f in files) {
      try { out.add(await rootBundle.loadString(f)); } catch (_) {}
    }
    return out;
  }
}
