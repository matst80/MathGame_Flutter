import 'package:flutter/material.dart';
import 'user.dart';
import 'userlist.dart';
import 'package:flutter_svg/svg.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:animated_background/animated_background.dart';

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
    width: 90,
    height: 145,
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
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 40,
            ),
            child: Material(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: Colors.white,
              child: AnimatedBackground(
                //behaviour: SpaceBehaviour(),
                behaviour: RandomParticleBehaviour(
                  options: ParticleOptions(
                    baseColor: Colors.green.shade400,
                    particleCount: 17,
                    spawnMaxRadius: 30,
                    spawnMaxSpeed: 100,
                    spawnMinSpeed: 10,
                    minOpacity: 0.03,
                    maxOpacity: 0.2,
                  ),
                ),
                vsync: this,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (BuildContext context, Widget child) {
                              return new CircularPercentIndicator(
                                radius: 90.0,
                                lineWidth: 8.0,
                                percent: _controller.value,
                                center: Countdown(
                                  animation: new StepTween(
                                    begin: kStartValue,
                                    end: 0,
                                  ).animate(_controller),
                                ),
                                progressColor: Colors.green,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
        fontSize: 45.0,
        color: Colors.black,
      ),
    );
  }
}
