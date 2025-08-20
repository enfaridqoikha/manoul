import 'package:flutter/material.dart';
import '../hf_api.dart';
import '../excerpts_loader.dart';
import '../local_bank.dart';
import '../models.dart';
import '../settings.dart';

class DailyScreen extends StatefulWidget { const DailyScreen({super.key}); @override State<DailyScreen> createState()=>_DailyScreenState(); }
AppLang _lang = AppLang.en;
class _DailyScreenState extends State<DailyScreen> {
  bool _loading = true;
  List<Question> _qs = [];
  int _i = 0; int _score = 0;
  final _excerpts = ExcerptsLoader();
  final _local = LocalBank();

  String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
  }

  @override void initState(){ super.initState(); _load(); }

  Future<void> _load(_lang = lang;) async {
    setState(()=>_loading=true);
    try {
      final (storedDate, storedCount) = await AppSettings.getDaily();
      final today = _today();
      final lang = await AppSettings.getLang();

      if (storedDate == today && storedCount == 25) {
        final local = await _local.loadAll(lang);
        _qs = local.take(25).toList();
      } else {
        final (key, model) = await AppSettings.getKeyModel();
        final ex = await _excerpts.load();
        if (key.isNotEmpty) {
          try {
            final qs = await HFClient(apiKey: key, model: model, lang: lang).generate(ex, count: 25);
            _qs = qs;
            await AppSettings.saveDaily(today, 25);
          } catch (_) {
            final local = await _local.loadAll(lang);
            _qs = local.take(25).toList();
          }
        } else {
          final local = await _local.loadAll(lang);
          _qs = local.take(25).toList();
        }
      }
    } finally {
      setState(()=>_loading=false);
    }
  }

  void _answer(bool ok){ if(ok) _score++; if(_i+1<_qs.length) setState(()=>_i++); else _finish(); }
  void _finish(){ showDialog(context: context, builder:(ctx)=>AlertDialog(title: const Text('Daily complete'), content: Text('Score: $_score / ${_qs.length}'), actions:[ TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text('Close')) ])); }

  @override Widget build(BuildContext context){
    if(_loading) return const Center(child:CircularProgressIndicator());
    final q=_qs[_i];
    return Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
      Text(q.topic, style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height:8),
      Text(q.text,
    style: Theme.of(context).textTheme.titleMedium,
    textDirection: _lang.dir
      const SizedBox(height:12),
      ...q.choices.map((c)=>Card(child: ListTile(title: Text('${c.id}. ${c.text}', textDirection: TextDirection.auto), onTap: ()=>_answer(c.isCorrect)))),
      const Spacer(),
      Text(q.text,
    style: Theme.of(context).textTheme.titleMedium,
    textDirection: _lang.dir
      if(q.explanation!=null)...[const SizedBox(height:8), Text('Note: ${q.explanation!}', style: Theme.of(context).textTheme.bodySmall, textDirection: TextDirection.auto)],
    ]));
  }
}
