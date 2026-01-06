import 'package:flutter/material.dart';
import '../../game/idle_game.dart';

class MonsterHpBar extends StatelessWidget {
  final IdleGame game;

  const MonsterHpBar({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: game.monsterHpNotifier,
      builder: (_, hp, __) {
        final maxHp = game.monster.maxHp;
        final ratio = (hp / maxHp).clamp(0.0, 1.0);

        return Column(
          children: [
            Text(
              'MONSTER HP',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 14,
                width: double.infinity,
                color: Colors.white.withOpacity(0.15),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: MediaQuery.of(context).size.width * ratio,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE53935), Color(0xFFFF7043)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${hp.toInt()} / ${maxHp.toInt()}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        );
      },
    );
  }
}
