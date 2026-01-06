import 'package:flutter/material.dart';
import '../game/idle_game.dart';

import 'widgets/top_info_bar.dart';
import 'widgets/monster_hp_bar.dart';
import 'widgets/bottom_action_bar.dart';

class GameHud extends StatelessWidget {
  final IdleGame game;

  const GameHud({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            TopInfoBar(game: game),
            const SizedBox(height: 16),
            MonsterHpBar(game: game),
            const Spacer(),
            BottomActionBar(game: game),
          ],
        ),
      ),
    );
  }
}
