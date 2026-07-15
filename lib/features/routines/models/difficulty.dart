enum Difficulty {
  beginner,
  intermediate,
  advanced;

  String toJson() {
    switch (this) {
      case Difficulty.beginner:
        return '쉬움';
      case Difficulty.intermediate:
        return '중간';
      case Difficulty.advanced:
        return '높음';
    }
  }

  static Difficulty fromJson(String json) {
    // Support both Korean and English for backward compatibility
    switch (json) {
      case '중간':
      case 'intermediate':
        return Difficulty.intermediate;
      case '높음':
      case 'advanced':
        return Difficulty.advanced;
      case '쉬움':
      case 'beginner':
      default:
        return Difficulty.beginner;
    }
  }

  String get displayName {
    switch (this) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.advanced:
        return 'Advanced';
    }
  }
}
