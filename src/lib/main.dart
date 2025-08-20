import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_screen.dart';
import 'screens/daily_screen.dart';
import 'screens/practice_screen.dart';

void main() => runApp(const ProviderScope(child: App()));

class App extends ConsumerWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'MEP Dubai AI',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      darkTheme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal, brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget { const Home({super.key}); @override State<Home> createState()=>_HomeState(); }
class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late final TabController _c = TabController(length: 2, vsync: this);
  @override void dispose(){ _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('MEP Dubai AI'),
        actions: [ IconButton(onPressed: ()=>Navigator.of(context).push(MaterialPageRoute(builder: (_)=>const SettingsScreen())), icon: const Icon(Icons.settings)) ],
        bottom: TabBar(controller: _c, tabs: const [ Tab(text:'Daily Practice'), Tab(text:'Practice Mode') ]),
      ),
      body: TabBarView(controller: _c, children: const [ DailyScreen(), PracticeScreen() ]),
    );
  }
}
