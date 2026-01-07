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
  final CombatState combat = CombatState();
  final MonsterState monster = MonsterState();

  SpriteComponent? background;
  SpriteComponent? monsterSprite;

  double gold = 0;
  final goldNotifier = ValueNotifier<double>(0);

  int stage = 1;
  final stageNotifier = ValueNotifier<int>(1);

  final dpsNotifier = ValueNotifier<double>(5);
  final monsterHpNotifier = ValueNotifier<double>(50);
  final stageClearedOnceNotifier = ValueNotifier<bool>(false);

  double dpsUpgradeCost = 20;
  bool stageClearedOnce = false;

  final Random _rand = Random();
  bool get isBossStage => stage % 5 == 0;

  Vector2 damageBasePosition = Vector2.zero();

  // ===== 연출 상태 =====
  double hitShakeTime = 0;
  bool isDying = false;
  double deathAnimTime = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    background = SpriteComponent(
      sprite: await loadSprite('bg_forest_pixel.png'),
      size: size,
      priority: -10,
    );
    add(background!);

    monsterSprite = SpriteComponent(
      sprite: await loadSprite('mushroom.png'),
      size: Vector2(160, 160),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2 + 80),
    );
    add(monsterSprite!);

    monsterHpNotifier.value = monster.hp;
    dpsNotifier.value = combat.dps;
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);

    background?.size = gameSize;
    monsterSprite?.position = Vector2(gameSize.x / 2, gameSize.y / 2 + 80);
    damageBasePosition = Vector2(gameSize.x / 2, gameSize.y / 2);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // =========================
    // 사망 연출 처리
    // =========================
    if (isDying) {
      deathAnimTime += dt;

      final t = (deathAnimTime / 0.4).clamp(0.0, 1.0);

      monsterSprite?.scale = Vector2.all(1.0 - t);
      monsterSprite?.opacity = 1.0 - t;

      if (t >= 1.0) {
        _finishDeath();
      }
      return;
    }

    // =========================
    // 피격 흔들림
    // =========================
    if (hitShakeTime > 0) {
      hitShakeTime -= dt;
      monsterSprite?.position.x = size.x / 2 + sin(hitShakeTime * 60) * 8;
    } else {
      monsterSprite?.position.x = size.x / 2;
    }

    if (!combat.canAttack(dt)) return;

    final damage = combat.dps;
    final killed = monster.takeDamage(damage);

    hitShakeTime = 0.15;

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
      _startDeath();
    }
  }

  // ===== 사망 연출 시작 =====
  void _startDeath() {
    isDying = true;
    deathAnimTime = 0;
  }

  // ===== 사망 연출 종료 =====
  void _finishDeath() {
    isDying = false;

    gold += monster.maxHp * (isBossStage ? 5 : 2);
    goldNotifier.value = gold;

    stageClearedOnce = true;
    stageClearedOnceNotifier.value = true;

    monster.reset();
    monsterHpNotifier.value = monster.hp;

    monsterSprite?.scale = Vector2.all(1);
    monsterSprite?.opacity = 1;
  }

  // ===== 업그레이드 =====
  void upgradeDps() {
    if (gold < dpsUpgradeCost) return;

    gold -= dpsUpgradeCost;
    goldNotifier.value = gold;

    combat.upgradeDps();
    dpsUpgradeCost *= 1.8;
    dpsNotifier.value = combat.dps;
  }

  // ===== 다음 스테이지 =====
  void goNextStage() {
    stage++;
    stageNotifier.value = stage;

    gold += stage * 20;
    goldNotifier.value = gold;

    monster.nextStage(isBoss: isBossStage);
    monsterHpNotifier.value = monster.hp;

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
