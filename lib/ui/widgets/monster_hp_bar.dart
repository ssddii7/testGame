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

        // 🔥 핵심: HP 표시용 값은 0 미만 방지
        final displayHp = hp < 0 ? 0 : hp;

        final ratio = (displayHp / maxHp).clamp(0.0, 1.0);

        final isBoss = game.isBossStage;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.45),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(
                isBoss ? 'BOSS HP' : 'MONSTER HP',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // HP BAR
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LayoutBuilder(
                  builder: (_, c) => Container(
                    height: isBoss ? 22 : 14,
                    color: Colors.white.withOpacity(0.15),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: c.maxWidth * ratio,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isBoss
                                ? const [Color(0xFF9C27B0), Color(0xFFE040FB)]
                                : const [Color(0xFFE53935), Color(0xFFFF7043)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // HP TEXT (0 이하 방지)
              Text(
                '${displayHp.toInt()} / ${maxHp.toInt()}',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }
}
