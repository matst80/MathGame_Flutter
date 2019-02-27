import 'package:flutter/material.dart';

class WaitScreen extends StatefulWidget {
  WaitScreen({Key key, this.winner}) : super(key: key);

  final String winner;

  @override
  _WaitScreen createState() => _WaitScreen();
}

var winnerTextStyle = TextStyle(fontWeight: FontWeight.normal, fontSize: 60);
var winnerStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 70);

class _WaitScreen extends State<WaitScreen> with TickerProviderStateMixin {
  AnimationController _controller;
  static const int kStartValue = 4;

  @override
  void initState() {
    super.initState();

    _controller = new AnimationController(
      duration: new Duration(seconds: kStartValue),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    var _lastWinner = widget.winner;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Vinnare:',
              style: winnerTextStyle,
            ),
            Text(
              _lastWinner,
              style: winnerStyle,
            ),
            Countdown(
              animation: new StepTween(
                begin: kStartValue,
                end: 1,
              ).animate(_controller),
            ),
          ],
        ),
      ),
    );
  }
}

class Countdown extends AnimatedWidget {
  Countdown({Key key, this.animation}) : super(key: key, listenable: animation);
  final Animation<int> animation;

  @override
  build(BuildContext context) {
    return new Text(
      animation.value.toString(),
      style: new TextStyle(fontSize: 150.0),
    );
  }
}
