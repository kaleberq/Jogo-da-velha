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
}
