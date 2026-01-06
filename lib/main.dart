import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/idle_game.dart';
import 'ui/hud.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final IdleGame game = IdleGame();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    game.loadOfflineReward();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      game.saveExitTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GameWidget(game: game),
            GameHud(game: game),
          ],
        ),
      ),
    );
  }
}
