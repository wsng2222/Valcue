enum MachineType {
  treadmill,
  cycle,
  stairmaster;

  String get displayName {
    switch (this) {
      case MachineType.treadmill:
        return '러닝머신';
      case MachineType.cycle:
        return '사이클';
      case MachineType.stairmaster:
        return '천국의 계단';
    }
  }

  String toJson() {
    switch (this) {
      case MachineType.treadmill:
        return 'treadmill';
      case MachineType.cycle:
        return 'cycle';
      case MachineType.stairmaster:
        return 'stairmaster';
    }
  }

  static MachineType fromJson(String json) {
    switch (json) {
      case 'cycle':
        return MachineType.cycle;
      case 'stairmaster':
        return MachineType.stairmaster;
      case 'treadmill':
      default:
        return MachineType.treadmill;
    }
  }
}
