import 'package:flutter/material.dart';
import 'user.dart';
import 'userlist.dart';

class WaitScreen extends StatefulWidget {
  WaitScreen({Key key, this.winner, this.users}) : super(key: key);

  final String winner;
  final List<User> users;

  @override
  _WaitScreen createState() => _WaitScreen();
}

var winnerTextStyle = TextStyle(
  fontWeight: FontWeight.normal,
  fontSize: 60,
  color: Colors.white,
);

var winnerStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 70,
  color: Colors.white,
);

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

  @override
  Widget build(BuildContext context) {
    var _lastWinner = widget.winner;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.blue,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'userlist',
                child: Material(
                  elevation: 4,
                  color: Colors.blue.shade700,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: UserList(users: widget.users),
                  ),
                ),
              ),
              SizedBox(height: 30),
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
                  end: 0,
                ).animate(_controller),
              ),
            ],
          ),
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
      style: new TextStyle(
        fontSize: 150.0,
        color: Colors.blue.shade200,
      ),
    );
  }
}
