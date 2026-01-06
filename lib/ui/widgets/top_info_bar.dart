import 'package:flutter/material.dart';
import '../../game/idle_game.dart';

class TopInfoBar extends StatelessWidget {
  final IdleGame game;

  const TopInfoBar({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Row(
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
