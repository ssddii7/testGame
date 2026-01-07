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
            // 🔝 상단 정보 (GOLD / STAGE / DPS)
            TopInfoBar(game: game),

            const Spacer(), // ← 몬스터 표시 영역 확보
            // ❤️ 몬스터 HP (하단)
            MonsterHpBar(game: game),

            const SizedBox(height: 12),

            // ⬇️ 하단 액션 버튼
            BottomActionBar(game: game),
          ],
        ),
      ),
    );
  }
}
