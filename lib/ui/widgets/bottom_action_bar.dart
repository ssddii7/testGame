import 'package:flutter/material.dart';
import '../../game/idle_game.dart';
import 'game_button.dart';

class BottomActionBar extends StatelessWidget {
  final IdleGame game;

  const BottomActionBar({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: game.stageClearedOnceNotifier,
      builder: (_, canNext, __) {
        return Row(
          children: [
            Expanded(
              flex: 3,
              child: ValueListenableBuilder<double>(
                valueListenable: game.goldNotifier,
                builder: (_, gold, __) {
                  final canUpgrade = gold >= game.dpsUpgradeCost;

                  return GameButton(
                    title: 'DPS UP',
                    subtitle: '${game.dpsUpgradeCost.toInt()} G',
                    enabled: canUpgrade,
                    colors: const [Color(0xFFF6B042), Color(0xFFF08A24)],
                    onPressed: game.upgradeDps,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: GameButton(
                title: 'NEXT STAGE',
                subtitle: '',
                enabled: canNext,
                colors: const [Color(0xFF7AC77A), Color(0xFF4CAF50)],
                onPressed: () {
                  if (canNext) game.goNextStage();
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
