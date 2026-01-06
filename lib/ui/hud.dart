import 'package:flutter/material.dart';
import '../game/idle_game.dart';

class GameHud extends StatelessWidget {
  final IdleGame game;

  const GameHud({super.key, required this.game});

  String _equipName(EquipmentType type) {
    switch (type) {
      case EquipmentType.sword:
        return 'Sword';
      case EquipmentType.axe:
        return 'Axe';
      case EquipmentType.staff:
        return 'Staff';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gold
        Positioned(
          top: 30,
          left: 20,
          child: ValueListenableBuilder<double>(
            valueListenable: game.goldNotifier,
            builder: (_, gold, __) => Text(
              'Gold: ${gold.toStringAsFixed(1)}',
              style: const TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),
        ),

        // DPS
        Positioned(
          top: 60,
          left: 20,
          child: ValueListenableBuilder<double>(
            valueListenable: game.dpsNotifier,
            builder: (_, dps, __) => Text(
              'DPS: ${dps.toStringAsFixed(1)}',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ),

        // Stage
        Positioned(
          top: 85,
          left: 20,
          child: ValueListenableBuilder<int>(
            valueListenable: game.stageNotifier,
            builder: (_, stage, __) => Text(
              game.isBossStage ? 'Stage $stage (BOSS)' : 'Stage $stage',
              style: TextStyle(
                color: game.isBossStage ? Colors.red : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // HP Bar
        Positioned(
          top: 115,
          left: 20,
          right: 20,
          child: ValueListenableBuilder<double>(
            valueListenable: game.monsterHpNotifier,
            builder: (_, hp, __) {
              final ratio = hp / game.monsterMaxHp;
              return LinearProgressIndicator(
                value: ratio.clamp(0, 1),
                backgroundColor: Colors.white24,
                color: game.isBossStage ? Colors.purple : Colors.red,
              );
            },
          ),
        ),

        // 🗡 장비 표시
        Positioned(
          top: 150,
          left: 20,
          child: ValueListenableBuilder<Map<EquipmentType, int>>(
            valueListenable: game.equipmentNotifier,
            builder: (_, eqs, __) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: EquipmentType.values.map((type) {
                  final count = eqs[type] ?? 0;
                  return Text(
                    '${_equipName(type)}: $count',
                    style: const TextStyle(color: Colors.lightBlueAccent),
                  );
                }).toList(),
              );
            },
          ),
        ),

        // 버튼 영역
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: Row(
            children: [
              // DPS 업그레이드
              Expanded(
                child: ValueListenableBuilder<double>(
                  valueListenable: game.goldNotifier,
                  builder: (_, gold, __) {
                    final canBuy = gold >= game.dpsUpgradeCost;
                    return ElevatedButton(
                      onPressed: canBuy ? game.upgradeDps : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canBuy ? Colors.orange : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'DPS UP\n${game.dpsUpgradeCost.toStringAsFixed(0)} G',
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // NEXT STAGE
              Expanded(
                child: ValueListenableBuilder<bool>(
                  valueListenable: game.stageClearedOnceNotifier,
                  builder: (_, show, __) {
                    if (!show) return const SizedBox.shrink();

                    return ElevatedButton(
                      onPressed: game.goNextStage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'NEXT STAGE',
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
