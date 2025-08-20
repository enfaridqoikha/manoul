import 'package:flutter/material.dart';
import '../hf_api.dart';
import '../excerpts_loader.dart';
import '../local_bank.dart';
import '../models.dart';
import '../settings.dart';

class PracticeScreen extends StatefulWidget { const PracticeScreen({super.key}); @override State<PracticeScreen> createState()=>_PracticeScreenState(); }
class _PracticeScreenState extends State<PracticeScreen> {
  bool _loading = true;
  List<Question> _qs = [];
  int _i = 0; int _score = 0;
  final _excerpts = ExcerptsLoader();
  final _local = LocalBank();

  @override void initState(){ super.initState(); _load(); }

  Future<void> _load() async {
    _lang = lang;
    setState(()=>_loading=true);
    try {
      final lang = await AppSettings.getLang();
      final (key, model) = await AppSettings.getKeyModel();
      final ex = await _excerpts.load();
      if (key.isNotEmpty) {
        try {
          _qs = await HFClient(apiKey: key, model: model, lang: lang).generate(ex, count: 40);
        } catch (_) {
          _qs = (await _local.loadAll(lang)).take(40).toList();
        }
      } else {
        _qs = (await _local.loadAll(lang)).take(40).toList();
      }
    } finally { setState(()=>_loading=false); }
  }

  void _answer(bool ok){ if(ok) _score++; if(_i+1<_qs.length) setState(()=>_i++); else _finish(); }
  void _finish(){ showDialog(context: context, builder:(ctx)=>AlertDialog(title: const Text('Practice complete'), content: Text('Score: $_score / ${_qs.length}'), actions:[
    TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text('Close')),
    FilledButton(onPressed: (){ Navigator.pop(ctx); setState(()=>_i=0); _load(); }, child: const Text('New Set'))
  ])); }

  @override Widget build(BuildContext context){
    if(_loading) return const Center(child:CircularProgressIndicator());
    final q=_qs[_i];
    return Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
      Text(q.topic, style: Theme.of(context).textTheme.labelLarge, textDirection: _lang.dir),
      const SizedBox(height:8),
      Text(q.text, style: Theme.of(context).textTheme.titleMedium, textDirection: _lang.dir),
      const SizedBox(height:12),
      ...q.choices.map((c)=>Card(child: ListTile(title: Text('${c.id}. ${c.text}', textDirection: TextDirection.auto), onTap: ()=>_answer(c.isCorrect)))),
      const Spacer(),
      Text('Ref: ${q.ref}', style: Theme.of(context).textTheme.bodySmall, textDirection: textDirection: _lang.dir),
      if(q.explanation!=null)...[const SizedBox(height:8), Text('Note: ${q.explanation!}', style: Theme.of(context).textTheme.bodySmall,textDirection: _lang.dir)],
    ]));
  }
}
