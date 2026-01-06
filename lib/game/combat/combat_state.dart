class CombatState {
  double baseDps = 5;
  double bonusDps = 0;

  double get dps => baseDps + bonusDps;

  double attackTimer = 0;

  /// 1초에 한 번 공격인지 체크
  bool canAttack(double dt) {
    attackTimer += dt;
    if (attackTimer >= 1.0) {
      attackTimer -= 1.0;
      return true;
    }
    return false;
  }

  void upgradeDps() {
    baseDps *= 1.5;
  }

  void addBonus(double value) {
    bonusDps += value;
  }
}
