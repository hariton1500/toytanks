import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Wall extends PositionComponent with GenericCollisionCallbacks<PositionComponent>{
  final Vector2 pos;
  Wall({required this.pos}) : super(size: Vector2.all(20));

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    debugPrint(intersectionPoints.toList().toString());
  }

  @override
  Future<void> onLoad() async {
    //sprite = await Sprite.load('tank.png');
    position = Vector2(pos.x * size.x, pos.y * size.y);
    //anchor = Anchor.center;
    //scale = Vector2.all(0.1);
  }
  @override
  Future<void> render(Canvas canvas) async {
    super.render(canvas);
    Paint paint = Paint()..color = Colors.white;
    Rect rect = Rect.fromCenter(center: const Offset(10, 10), width: 20, height: 20);
    canvas.drawRect(rect, paint);
  }
  
}