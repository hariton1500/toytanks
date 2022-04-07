// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:toytanks/elements/bullet.dart';

class ToyScreen extends StatefulWidget {
  const ToyScreen({ Key? key }) : super(key: key);

  @override
  State<ToyScreen> createState() => _ToyScreenState();
}

class _ToyScreenState extends State<ToyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  int startPoint = 0;
  int endPoint = 100;
  double angle = 0;
  double angleHead = 0;
  double? width, height;
  List<List<double>> world = List.generate(500, (index) => [50.0+index, 50]);
  List<Bullet>? bullets = [];
  DateTime shotTime = DateTime.now();
  bool tankCanShoot = true;
  //Offset center = Offset(0, 0);
  static const tankForwardSpeed = 2, tankBackSpeed = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    Timer.periodic(Duration(milliseconds: (1000 / 60).ceil()), (timer) => frame(bullets!));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      //appBar: AppBar(),
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (input) {
          //print(angle);
          //print('=${input.logicalKey.keyId}=');
          if (input.logicalKey.keyId == 32 && tankCanShoot) {
            setState(() {
              //create bullet
              Bullet bullet = Bullet(flightAngle: angleHead, height: 10, x: 0, y: 0, startTime: DateTime.now().millisecondsSinceEpoch);
              bullets!.add(bullet);
              shotTime = DateTime.now();
              tankCanShoot = false;
              print(bullets);
            });
          }
          if (input.logicalKey.keyLabel == 'Arrow Right') {
            setState(() {
              angle-=pi/180;
              angleHead-=pi/180;
            });
          }
          if (input.logicalKey.keyLabel == 'D') {
            setState(() {
              angleHead-=pi/90;
            });
          }
          if (input.logicalKey.keyLabel == 'Arrow Left') {
            setState(() {
              angle+=pi/180;
              angleHead+=pi/180;
            });
          }
          if (input.logicalKey.keyLabel == 'A') {
            setState(() {
              angleHead+=pi/90;
            });
          }
          if (input.logicalKey.keyLabel == 'Arrow Up') {
            setState(() {
              if (isOversNotFound()) {
                //print('no overs');
                for (var point in world) {
                  point[0]+=sin(angle) * tankForwardSpeed;
                  point[1]+=cos(angle) * tankForwardSpeed;
                }
              } else {
                for (var point in world) {
                  point[0]-=sin(angle) * tankForwardSpeed * 2;
                  point[1]-=cos(angle) * tankForwardSpeed * 2;
                }
                //print('overs found');
              }
            });
          }
          if (input.logicalKey.keyLabel == 'Arrow Down') {
            setState(() {
              if (isOversNotFound()) {
                for (var point in world) {
                  point[0]-=sin(angle) * tankBackSpeed;
                  point[1]-=cos(angle) * tankBackSpeed;
                }
              } else {
                for (var point in world) {
                  point[0]+=sin(angle) * tankBackSpeed * 2;
                  point[1]+=cos(angle) * tankBackSpeed * 2;
                }
              }
            });
          }
        },
        child: CustomPaint(
          painter: ShapePainter(angle, world, angleHead, bullets!),
          child: Container(
            //width: 400,
            //height: 400,
            //color: Colors.white,
          ),
        ),
      ),
    );
  }

  bool isOversNotFound() {
    return world.every((point) => sqrt((point[0] - width! / 2) * (point[0] - width! / 2) + (point[1] - height! / 2) * (point[1] - height! / 2)) >= sqrt(21*21 + 30*30));
  }
  void frame(List<Bullet> bullets) {
    //check last shooting
    if (DateTime.now().difference(shotTime) >= const Duration(seconds: 3)) {
      tankCanShoot = true;
    }
    //calculate moving of bullets
    List<int> indexesToRemove = [];
    for (var bullet in bullets) {
      print(bullets.indexOf(bullet));
      bullet.moveTick();
      if (bullet.height! <= 0) {
        indexesToRemove.add(bullets.indexOf(bullet));
      }
    }
    for (var index in indexesToRemove) {
      bullets.removeAt(index);
    }
    setState(() {
      
    });
  }
}

class ShapePainter extends CustomPainter{
  final double angle, angleHead;
  final List<List<double>> world;
  final List<Bullet> bullets;
  ShapePainter(this.angle, this.world, this.angleHead, this.bullets);

  @override
  void paint(Canvas canvas, Size size) {
    const tankWidth = 21;
    const tankHeight = 30;
    const tankHeadWidth = 9;
    const tankHeadHeight = 12;
    final radius = sqrt(tankWidth*tankWidth + tankHeight*tankHeight)/2;
    final radiusHead = sqrt(tankHeadWidth*tankHeadWidth + tankHeadHeight*tankHeadHeight)/2;
    double angleDelta = atan(tankHeight/tankWidth);//*pi/2;
    double angleHeadDelta = atan(tankHeadHeight/tankHeadWidth);

    final centerX = size.width / 2;
    final centerY = size.height / 2;


    var paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    var paintG = Paint()
      ..color = Colors.green
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    //world
    canvas.drawPoints(PointMode.points, world.map((e) => Offset(e[0], e[1])).toList(), paintG);


    //tank
    Offset pointUR = Offset(centerX+radius*cos(angle+angleDelta), centerY-radius*sin(angle+angleDelta));
    Offset pointUL = Offset(centerX+radius*cos(angle+pi-angleDelta), centerY-radius*sin(angle+pi-angleDelta));
    Offset pointDL = Offset(centerX+radius*cos(angle-pi+angleDelta), centerY-radius*sin(angle-pi+angleDelta));
    Offset pointDR = Offset(centerX+radius*cos(angle-angleDelta), centerY-radius*sin(angle-angleDelta));
    canvas.drawLine(pointUL, pointUR, paint);
    canvas.drawLine(pointUR, pointDR, paint);
    canvas.drawLine(pointDR, pointDL, paint);
    canvas.drawLine(pointDL, pointUL, paint);
    //tankHead
    Offset pointHUR = Offset(centerX+radiusHead*cos(angleHead+angleHeadDelta), centerY-radiusHead*sin(angleHead+angleHeadDelta));
    Offset pointHUL = Offset(centerX+radiusHead*cos(angleHead+pi-angleHeadDelta), centerY-radiusHead*sin(angleHead+pi-angleHeadDelta));
    Offset pointHDL = Offset(centerX+radiusHead*cos(angleHead-pi+angleHeadDelta), centerY-radiusHead*sin(angleHead-pi+angleHeadDelta));
    Offset pointHDR = Offset(centerX+radiusHead*cos(angleHead-angleHeadDelta), centerY-radiusHead*sin(angleHead-angleHeadDelta));
    canvas.drawLine(pointHUL, pointHUR, paint);
    canvas.drawLine(pointHUR, pointHDR, paint);
    canvas.drawLine(pointHDR, pointHDL, paint);
    canvas.drawLine(pointHDL, pointHUL, paint);
    //tankWeapon
    canvas.drawLine(Offset(centerX, centerY), Offset(centerX+tankHeight*cos(angleHead+pi/2), centerY-tankHeight*sin(angleHead+pi/2)), paint);

    //bullets
    for (var bullet in bullets) {
      Offset pointBullet = Offset(centerX + bullet.x!, centerY + bullet.y!);
      canvas.drawCircle(pointBullet, 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
  
}