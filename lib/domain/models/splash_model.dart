import 'dart:async';

class SplashModel {
  int currentIndex;
  Timer? boardAnimationTimer;
  bool hasStartedBoardAnimation;

  SplashModel({
    this.currentIndex = 0,
    this.boardAnimationTimer,
    this.hasStartedBoardAnimation = false,
  });

  void reset() {
    boardAnimationTimer?.cancel();
    currentIndex = 0;
    boardAnimationTimer = null;
    hasStartedBoardAnimation = false;
  }

  void cancelTimer() {
    boardAnimationTimer?.cancel();
    boardAnimationTimer = null;
  }

  void incrementIndex() {
    currentIndex++;
  }
}
