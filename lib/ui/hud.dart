import 'package:flutter/material.dart';
import '../game/idle_game.dart';

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
            // ===============================
            // 상단 정보 + HP BAR
            // ===============================
            Column(
              children: [
                // GOLD / DPS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ValueListenableBuilder<double>(
                      valueListenable: game.goldNotifier,
                      builder: (_, gold, __) {
                        return _infoBox(
                          title: 'GOLD',
                          value: gold.toInt().toString(),
                          color: const Color(0xFFF6B042),
                        );
                      },
                    ),
                    ValueListenableBuilder<double>(
                      valueListenable: game.dpsNotifier,
                      builder: (_, dps, __) {
                        return _infoBox(
                          title: 'DPS',
                          value: dps.toStringAsFixed(1),
                          color: const Color(0xFF7AC77A),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ===== 몬스터 HP BAR (🔥 복구됨)
                ValueListenableBuilder<double>(
                  valueListenable: game.monsterHpNotifier,
                  builder: (_, hp, __) {
                    final ratio = (hp / game.monsterMaxHp).clamp(0.0, 1.0);

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
                                width:
                                    MediaQuery.of(context).size.width * ratio,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFE53935),
                                      Color(0xFFFF7043),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${hp.toInt()} / ${game.monsterMaxHp.toInt()}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),

            const Spacer(),

            // ===============================
            // 하단 버튼 영역
            // ===============================
            ValueListenableBuilder<bool>(
              valueListenable: game.stageClearedOnceNotifier,
              builder: (_, canNext, __) {
                return Row(
                  children: [
                    // DPS UP
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
                            colors: const [
                              Color(0xFFF6B042),
                              Color(0xFFF08A24),
                            ],
                            onPressed: game.upgradeDps,
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    // NEXT STAGE
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
            ),
          ],
        ),
      ),
    );
  }

  // ===============================
  // INFO BOX
  // ===============================
  Widget _infoBox({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// GAME BUTTON
/// ===============================
class GameButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> colors;
  final VoidCallback onPressed;
  final bool enabled;

  const GameButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
