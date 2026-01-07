import 'package:flutter/material.dart';
import '../../game/idle_game.dart';

class TopInfoBar extends StatelessWidget {
  final IdleGame game;

  const TopInfoBar({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 좌우 GOLD / DPS
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

        // 🔥 STAGE 중앙
        ValueListenableBuilder<int>(
          valueListenable: game.stageNotifier,
          builder: (_, stage, __) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'STAGE $stage',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

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
