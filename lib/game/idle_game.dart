import 'dart:math';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'damage_text.dart';

enum EquipmentType { sword, axe, staff }

class IdleGame extends FlameGame {
  // ===== 기본 재화 =====
  double gold = 0;
  final goldNotifier = ValueNotifier<double>(0);

  // ===== 전투 =====
  double baseDps = 5;
  double bonusDps = 0;
  double get dps => baseDps + bonusDps;
  final dpsNotifier = ValueNotifier<double>(5);

  // ===== 스테이지 =====
  int stage = 1;
  final stageNotifier = ValueNotifier<int>(1);

  // ===== 몬스터 HP (개념만) =====
  double monsterMaxHp = 50;
  double monsterHp = 50;
  final monsterHpNotifier = ValueNotifier<double>(50);

  // ===== 1초 공격 타이머 (🔥 핵심) =====
  double attackTimer = 0;

  // ===== 데미지 숫자 위치 (화면 중앙) =====
  Vector2 damageBasePosition = Vector2.zero();

  // ===== 업그레이드 =====
  double dpsUpgradeCost = 20;

  // ===== NEXT STAGE =====
  bool stageClearedOnce = false;
  final stageClearedOnceNotifier = ValueNotifier<bool>(false);

  // ===== 장비 =====
  final Map<EquipmentType, int> equipments = {
    EquipmentType.sword: 0,
    EquipmentType.axe: 0,
    EquipmentType.staff: 0,
  };

  final equipmentNotifier = ValueNotifier<Map<EquipmentType, int>>({});

  final Random _rand = Random();

  bool get isBossStage => stage % 5 == 0;

  // ===== 화면 크기 확정 =====
  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);

    damageBasePosition = Vector2(gameSize.x / 2, gameSize.y / 2);
  }

  // ===== 메인 루프 =====
  @override
  void update(double dt) {
    super.update(dt);

    attackTimer += dt;

    // 🔥 1초에 한 번만 공격
    if (attackTimer >= 1.0) {
      attackTimer -= 1.0;

      final damage = dps;
      monsterHp -= damage;

      // 데미지 숫자 (1초 1번)
      camera.viewport.add(
        DamageText(
          position: damageBasePosition.clone()
            ..add(
              Vector2(_rand.nextDouble() * 30 - 15, _rand.nextDouble() * 10),
            ),
          damage: damage.round(),
        ),
      );

      if (monsterHp <= 0) {
        // 골드 드랍
        gold += monsterMaxHp * (isBossStage ? 1.2 : 0.5);
        goldNotifier.value = gold;

        // 보스 장비 드랍
        if (isBossStage) {
          _tryDropEquipment();
        }

        // NEXT STAGE 버튼 활성
        if (!stageClearedOnce) {
          stageClearedOnce = true;
          stageClearedOnceNotifier.value = true;
        }

        monsterHp = monsterMaxHp;
      }

      monsterHpNotifier.value = monsterHp;
    }
  }

  // ===== DPS 업그레이드 =====
  void upgradeDps() {
    if (gold < dpsUpgradeCost) return;

    gold -= dpsUpgradeCost;
    baseDps *= 1.5;
    dpsUpgradeCost *= 1.8;

    goldNotifier.value = gold;
    _updateDps();
  }

  // ===== NEXT STAGE =====
  void goNextStage() {
    stage++;

    gold += stage * 10;
    goldNotifier.value = gold;

    monsterMaxHp *= isBossStage ? 2.0 : 1.4;
    monsterHp = monsterMaxHp;

    stageNotifier.value = stage;

    stageClearedOnce = false;
    stageClearedOnceNotifier.value = false;
  }

  // ===== 장비 드랍 =====
  void _tryDropEquipment() {
    const dropChance = 0.3;
    if (_rand.nextDouble() > dropChance) return;

    final type =
        EquipmentType.values[_rand.nextInt(EquipmentType.values.length)];
    equipments[type] = equipments[type]! + 1;

    switch (type) {
      case EquipmentType.sword:
        bonusDps += 5;
        break;
      case EquipmentType.axe:
        bonusDps += 8;
        break;
      case EquipmentType.staff:
        bonusDps += 6;
        break;
    }

    equipmentNotifier.value = Map.from(equipments);
    _updateDps();
  }

  void _updateDps() {
    dpsNotifier.value = dps;
  }

  // ===== 오프라인 보상 =====
  Future<void> loadOfflineReward() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt('lastExitTime');

    if (last != null) {
      final diff = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(last),
      );

      final offlineGold = diff.inSeconds * dps;
      gold += offlineGold;
      goldNotifier.value = gold;
    }
  }

  Future<void> saveExitTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastExitTime', DateTime.now().millisecondsSinceEpoch);
  }
}
