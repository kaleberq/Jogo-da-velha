import 'dart:async';

class SplashModel {
  final int currentIndex;
  final Timer? boardAnimationTimer;
  final bool hasStartedBoardAnimation;

  const SplashModel({
    this.currentIndex = 0,
    this.boardAnimationTimer,
    this.hasStartedBoardAnimation = false,
  });

  SplashModel copyWith({
    int? currentIndex,
    Timer? boardAnimationTimer,
    bool clearBoardAnimationTimer = false,
    bool? hasStartedBoardAnimation,
  }) {
    return SplashModel(
      currentIndex: currentIndex ?? this.currentIndex,
      boardAnimationTimer: clearBoardAnimationTimer
          ? null
          : (boardAnimationTimer ?? this.boardAnimationTimer),
      hasStartedBoardAnimation:
          hasStartedBoardAnimation ?? this.hasStartedBoardAnimation,
    );
  }
}
