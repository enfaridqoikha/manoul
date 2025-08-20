import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'models.dart';
import 'settings.dart';

class LocalBank {
  final _rand = Random();

  Future<List<Question>> loadAll(AppLang lang) async {
    final manifest = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> map = json.decode(manifest);
    final dir = lang == AppLang.ar ? 'assets/questions/ar/' : 'assets/questions/en/';
    final paths = map.keys.where((k) => k.startsWith(dir) && k.endsWith('.json')).toList();
    final List<Question> all = [];
    for (final p in paths) {
      final txt = await rootBundle.loadString(p);
      final List data = json.decode(txt);
      all.addAll(data.map((e) => Question.fromJson(e)).toList());
    }
    all.addAll(_parametric(60, lang));
    all.shuffle(_rand);
    return all;
  }

  List<Question> _parametric(int n, AppLang lang) {
    final List<Question> out = [];
    for (int i = 0; i < n; i++) {
      final double kw = 2 + _rand.nextInt(28).toDouble();
      final pf = [0.8, 0.85, 0.9, 0.95][_rand.nextInt(4)];
      final v = [230, 400][_rand.nextInt(2)];
      final ib = (kw * 1000) / (v * pf);
      final rounded = (ib / 5).ceil() * 5;
      final opts = <Choice>[
        Choice(id: 'A', text: '${(rounded - 10).clamp(5, 400)} A', isCorrect: false),
        Choice(id: 'B', text: '${rounded.toStringAsFixed(0)} A', isCorrect: true),
        Choice(id: 'C', text: '${(rounded + 5).clamp(5, 400)} A', isCorrect: false),
        Choice(id: 'D', text: '${(rounded - 5).clamp(5, 400)} A', isCorrect: false),
      ]..shuffle(_rand);
      out.add(Question(
        id: 'p_$i',
        text: lang == AppLang.ar
            ? 'محرك قدرة ${kw.toStringAsFixed(1)} ك.و عند جهد $v فولت ومعامل قدرة $pf. ما أقرب تيار تصميم؟'
            : 'A ${kw.toStringAsFixed(1)} kW motor at $v V, PF $pf. Nearest design current?',
        choices: opts,
        topic: lang == AppLang.ar ? 'كهرباء — حسابات' : 'Electrical — Sizing',
        ref: 'Practice',
        explanation: lang == AppLang.ar
            ? 'I_b = P / (V × PF) ثم التقريب لأقرب 5 أمبير.'
            : 'I_b = P / (V × PF); round to nearest 5 A.'
      ));
    }
    return out;
  }
}
