import 'package:flutter/material.dart';
import 'user.dart';
import 'userlist.dart';
import 'dart:math';
import 'package:flutter_svg/svg.dart';

class WaitScreen extends StatefulWidget {
  WaitScreen({Key key, this.winner, this.users}) : super(key: key);

  final String winner;
  final List<User> users;

  @override
  _WaitScreen createState() => _WaitScreen();
}

class _WaitScreen extends State<WaitScreen> with TickerProviderStateMixin {
  AnimationController _controller;
  static const int kStartValue = 3;

  @override
  void initState() {
    super.initState();

    _controller = new AnimationController(
      duration: new Duration(seconds: kStartValue),
      vsync: this,
    );
    _controller.forward();
  }

  final Widget trophy = new SvgPicture.asset(
    'assets/trophy.svg',
    width: 220,
    height: 280,
  );

  @override
  Widget build(BuildContext context) {
    var _lastWinner = widget.winner;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white.withAlpha(190),
        body: Container(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Material(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: Colors.white,
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Hero(
                    tag: 'userlist',
                    child: Material(
                      elevation: 0,
                      color: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: UserList(users: widget.users),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  trophy,
                  SizedBox(height: 10),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'WINNER',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 30,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _lastWinner,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 50,
                            color: Colors.black,
                          ),
                        ),
                        Stack(children: <Widget>[
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _controller,
                              builder: (BuildContext context, Widget child) {
                                return CustomPaint(
                                  painter: TimerPainter(
                                    animation: _controller,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                          Align(
                            alignment: FractionalOffset.center,
                            child: Countdown(
                              animation: new StepTween(
                                begin: kStartValue,
                                end: 0,
                              ).animate(_controller),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  TimerPainter({this.animation, this.color}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    //canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);

    double progress = (1.0 - animation.value) * 2 * pi;
    canvas.drawArc(Offset.zero & size, pi, -progress, false, paint);
  }

  @override
  bool shouldRepaint(TimerPainter old) {
    return animation.value != old.animation.value;
  }
}

class Countdown extends AnimatedWidget {
  Countdown({Key key, this.animation}) : super(key: key, listenable: animation);
  final Animation<int> animation;

  @override
  build(BuildContext context) {
    return new Text(
      animation.value.toString(),
      style: new TextStyle(
        fontSize: 150.0,
        color: Colors.blue.shade200,
      ),
    );
  }
}
