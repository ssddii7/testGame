import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'combat/combat_state.dart';
import 'monster/monster_state.dart';
import 'combat/damage_text.dart';

enum EquipmentType { sword, axe, staff }

class IdleGame extends FlameGame {
  // ===== STATE =====
  final CombatState combat = CombatState();
  final MonsterState monster = MonsterState();

  // ===== 배경 =====
  SpriteComponent? background;

  // ===== 재화 =====
  double gold = 0;
  final goldNotifier = ValueNotifier<double>(0);

  // ===== 스테이지 =====
  int stage = 1;
  final stageNotifier = ValueNotifier<int>(1);

  // ===== UI Notifier =====
  final dpsNotifier = ValueNotifier<double>(5);
  final monsterHpNotifier = ValueNotifier<double>(50);
  final stageClearedOnceNotifier = ValueNotifier<bool>(false);

  // ===== 업그레이드 =====
  double dpsUpgradeCost = 20;

  // ===== NEXT STAGE =====
  bool stageClearedOnce = false;

  final Random _rand = Random();

  bool get isBossStage => stage % 5 == 0;

  // ===== 데미지 텍스트 기준 위치 =====
  Vector2 damageBasePosition = Vector2.zero();

  // ===== 로드 =====
  @override
  Future<void> onLoad() async {
    super.onLoad();

    // 🔥 이미지 배경
    final sprite = await loadSprite('bg_forest_pixel.png');

    background = SpriteComponent(
      sprite: sprite,
      position: Vector2.zero(),
      size: size,
      priority: -10, // 항상 맨 뒤
    );

    add(background!);
  }

  // ===== 화면 크기 =====
  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);

    // 배경 사이즈 갱신
    if (background != null) {
      background!.size = gameSize;
    }

    damageBasePosition = Vector2(gameSize.x / 2, gameSize.y / 2);
  }

  // ===== 메인 루프 =====
  @override
  void update(double dt) {
    super.update(dt);

    if (!combat.canAttack(dt)) return;

    final damage = combat.dps;
    final killed = monster.takeDamage(damage);

    // 데미지 숫자
    camera.viewport.add(
      DamageText(
        position: damageBasePosition.clone()
          ..add(Vector2(_rand.nextDouble() * 30 - 15, _rand.nextDouble() * 10)),
        damage: damage.round(),
      ),
    );

    monsterHpNotifier.value = monster.hp;
    dpsNotifier.value = combat.dps;

    if (killed) {
      _onMonsterKilled();
    }
  }

  // ===== 몬스터 처치 =====
  void _onMonsterKilled() {
    gold += monster.maxHp * (isBossStage ? 1.2 : 0.5);
    goldNotifier.value = gold;

    if (!stageClearedOnce) {
      stageClearedOnce = true;
      stageClearedOnceNotifier.value = true;
    }

    monster.reset();
  }

  // ===== DPS 업그레이드 =====
  void upgradeDps() {
    if (gold < dpsUpgradeCost) return;

    gold -= dpsUpgradeCost;
    goldNotifier.value = gold;

    combat.upgradeDps();
    dpsUpgradeCost *= 1.8;

    dpsNotifier.value = combat.dps;
  }

  // ===== NEXT STAGE =====
  void goNextStage() {
    stage++;

    gold += stage * 10;
    goldNotifier.value = gold;

    monster.nextStage(isBoss: isBossStage);
    monsterHpNotifier.value = monster.hp;

    stageNotifier.value = stage;

    stageClearedOnce = false;
    stageClearedOnceNotifier.value = false;
  }

  // ===== 오프라인 보상 =====
  Future<void> loadOfflineReward() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt('lastExitTime');

    if (last != null) {
      final diff = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(last),
      );

      gold += diff.inSeconds * combat.dps;
      goldNotifier.value = gold;
    }
  }

  Future<void> saveExitTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastExitTime', DateTime.now().millisecondsSinceEpoch);
  }
}
