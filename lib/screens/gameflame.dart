import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
//import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
//import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toytanks/components/walls.dart';

class MyMap {
  late List<String> _map;
  MyMap({required int index}) {
    _map = [];
    _map.add('============================================================');
    _map.add('=----------------------------------------------------------=');
    _map.add('=----------------------------------------------------------=');
    _map.add('=--------======--------------------------------------------=');
    _map.add('=--------=----=--------------------------------------------=');
    _map.add('=--------=----=--------------------------------------------=');
    _map.add('=--------=----=--------------------------------------------=');
    _map.add('=--------=----=--------------------------------------------=');
    _map.add('=--------======--------------------------------------------=');
    _map.add('=----------------------------------------------------------=');
    _map.add('=-----------------------1----------------------------------=');
    _map.add('=-------------------------------------====-----------------=');
    _map.add('=-------------------------------------====-----------------=');
    _map.add('=-------------------------------------====-----------------=');
    _map.add('=----------------------------------------------------------=');
    _map.add('=----------------------------------------------------------=');
    _map.add('=----------------------------------------------------------=');
    _map.add('=----------------------------------------------------------=');
    _map.add('============================================================');
  }
}

class MyTankWeapon extends SpriteComponent {
  MyTankWeapon() : super(size: Vector2(68, 134));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('gunturret.png');
    anchor = Anchor.center;
    positionType = PositionType.game;
    scale = Vector2.all(0.4);
  }

}

class MyTank extends SpriteComponent with GenericCollisionCallbacks {
  MyTank() : super(size: Vector2(182, 188));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('tank.png');
    anchor = Anchor.center;
    scale = Vector2.all(0.4);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position = size / 2;
  }
}


class MyGame extends FlameGame with KeyboardEvents, HasCollisionDetection {
  //late final SpriteComponent myTank;
  final myTank = MyTank();
  final myTankWeapon = MyTankWeapon();
  
  final myMap = MyMap(index: 1);
  
  final List<Wall> walls = [];
  final WebSocket _ws;

  MyGame(this._ws);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(myTank);
    add(myTankWeapon);
    for (var i = 0; i < myMap._map.length; i++) {
      String row = myMap._map[i];
      debugPrint(':' + row);
      for (var j = 0; j < row.length; j++) {
        debugPrint(':' + row[j]);
        switch (row[j]) {
          case '=': //wall
            walls.add(Wall(pos: Vector2(i.toDouble(), j.toDouble())));
            break;
          case '-': //field
            break;
          case '1': //player
            myTank.position = Vector2(i * 20, j * 20);
            myTankWeapon.position = myTank.position;
            //camera.snapTo(myTank.position);
            break;
          default:
        }
      }
    }
    addAll(walls);
  }

  @override
  Future<void> update(double dt) async {
    super.update(dt);
    //myTank.x += dt * 10;
    //myTank.y += dt * 10;
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    //final isKeyDown = event is RawKeyDownEvent;
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      for (var wall in walls) {
        wall.position = Vector2(wall.x + cos(myTank.angle + pi / 2), wall.y - sin(myTank.angle - pi / 2));
      }
      debugPrint('up');
      _ws.add(jsonEncode({'data' : 'up'}));
      return KeyEventResult.handled;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      for (var wall in walls) {
        wall.position = Vector2(wall.x - cos(myTank.angle + pi / 2), wall.y + sin(myTank.angle - pi / 2));
      }
      debugPrint('down');
      return KeyEventResult.handled;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      MyTank2().changeSpeed(faster: false);
      debugPrint('left');
      turnLeft();
      return KeyEventResult.handled;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      MyTank2().changeSpeed(faster: false);
      debugPrint('right');
      turnRight();
      return KeyEventResult.handled;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
      MyTank2().changeSpeed(faster: false);
      debugPrint('A');
      turnWeaponLeft();
      return KeyEventResult.handled;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
      MyTank2().changeSpeed(faster: false);
      debugPrint('D');
      turnWeaponRight();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void turnLeft() {
    myTank.angle -= pi / 30;
  }
  void turnRight() {
    myTank.angle += pi / 30;
  }
  void turnWeaponLeft() {
    myTankWeapon.angle -= pi / 20;
  }
  void turnWeaponRight() {
    myTankWeapon.angle += pi / 20;
  }
}

class MySpriteTank extends SpriteComponent {
  MySpriteTank() :super();
}



class MyTank2 extends PositionComponent{
  static const double tankWidth = 21, tankHeight = 30;
  static Paint white = BasicPalette.white.paint();
  double speed = 0, maxForvardSpeed = 5, maxBackSpeed = 3, speedDelta = 1;

  MyTank2() : super(position: Vector2(100, 100));
  void changeSpeed({required bool faster}) {
    if (faster) {
      speed += speedDelta;
    } else {
      speed -= speedDelta;
    }
    if (speed < -maxBackSpeed) {
      speed = -maxBackSpeed;
    }
    if (speed > maxForvardSpeed) {
      speed = maxForvardSpeed;
    }
  }
}