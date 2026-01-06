class MonsterState {
  double maxHp = 50;
  double hp = 50;

  void reset() {
    hp = maxHp;
  }

  bool takeDamage(double damage) {
    hp -= damage;
    return hp <= 0;
  }

  void nextStage({required bool isBoss}) {
    maxHp *= isBoss ? 2.0 : 1.4;
    reset();
  }
}
