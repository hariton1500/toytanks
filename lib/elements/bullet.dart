// ignore_for_file: avoid_print

import 'dart:math';

class Bullet {
  int startSpeed = 20;
  double? flightAngle;
  double? height;
  double? x, y;
  static const double heightSpeed = 0.3;
  int? startTime;

  Bullet({required this.flightAngle, required this.height, required this.x, required this.y, required this.startTime});

  void moveTick() {
    int deltaTime = DateTime.now().millisecondsSinceEpoch - startTime!;
    x = x! - deltaTime / 1000 * startSpeed * cos(flightAngle! - pi/2);
    y = y! + deltaTime / 1000 * startSpeed * sin(flightAngle! - pi/2);
    height = height! - deltaTime / 1000 * heightSpeed;
    print('=======${DateTime.now()}=====$deltaTime========');
    print('x=$x  y=$y  h=$height');
  }
}