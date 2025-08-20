import 'package:flutter/material.dart';
import 'settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _key = TextEditingController();
  final _model = TextEditingController(text: 'google/flan-t5-large');
  AppLang _lang = AppLang.en;
  bool _loading = true;

  @override void initState(){ super.initState(); _load(); }
  Future<void> _load() async {
    final pair = await AppSettings.getKeyModel();
    final lang = await AppSettings.getLang();
    _key.text = pair.$1; _model.text = pair.$2; _lang = lang;
    setState(()=>_loading=false);
  }

  Future<void> _save() async {
    await AppSettings.setKeyModel(_key.text, _model.text);
    await AppSettings.setLang(_lang);
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
  }

  @override Widget build(BuildContext context){
    if(_loading) return const Scaffold(body: Center(child:CircularProgressIndicator()));
    return Scaffold(appBar: AppBar(title: const Text('Settings')), body: Padding(padding: const EdgeInsets.all(16), child: Column(
      children:[
        TextField(controller:_key, decoration: const InputDecoration(labelText:'Hugging Face API Key (hf_...)')),
        const SizedBox(height:12),
        TextField(controller:_model, decoration: const InputDecoration(labelText:'Model (e.g. google/flan-t5-large)')),
        const SizedBox(height:12),
        Row(children:[
          const Text('Language:'), const SizedBox(width:12),
          DropdownButton<AppLang>(value:_lang, items: const [
            DropdownMenuItem(value: AppLang.en, child: Text('English')),
            DropdownMenuItem(value: AppLang.ar, child: Text('العربية')),
          ], onChanged: (v){ if(v!=null) setState(()=>_lang=v); }),
        ]),
        const SizedBox(height:12),
        FilledButton(onPressed:_save, child: const Text('Save')),
        const SizedBox(height:12),
        const Text('Free key: HuggingFace → Settings → Access Tokens → New Token (Read).', textAlign: TextAlign.center),
      ],
    )));
  }
}
