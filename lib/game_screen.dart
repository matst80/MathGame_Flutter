import 'package:flutter/material.dart';
import 'calculation_question.dart';
import 'utils.dart';
import 'network_helper.dart';
import 'countdown.dart';
import 'round.dart';
import 'user.dart';
import 'userlist.dart';
import 'package:flutter_svg/svg.dart';
import 'package:animated_background/animated_background.dart';

typedef void AnswerPressed(double answer);

Widget buildAnswers(
    List<double> answers, AnswerPressed onAnswer, BuildContext context) {
  var answerWidgets = shuffle(answers
      .map(
        (answer) => RaisedButton(
              color: Colors.white,
              onPressed: () => onAnswer(answer),
              elevation: 10,
              padding: EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(90.0),
              ),
              key: Key(answer.toString()),
              child: SizedBox(
                width: 100,
                height: 100,
                child: Center(
                  child: Text(
                    answer.toInt().toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
              ),
            ),
      )
      .toList());
  return Padding(
    padding: const EdgeInsets.fromLTRB(22, 40, 22, 40),
    child: Wrap(
      spacing: 45,
      alignment: WrapAlignment.center,
      runSpacing: 25,
      children: answerWidgets,
    ),
  );
}

class GameScreen extends StatefulWidget {
  GameScreen({Key key, this.title, this.name}) : super(key: key);

  final String title;
  final String name;

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  List<User> _users = List<User>();
  String _lastWinner = '';
  User _me;
  double _monsterBottom = -10;
  CalculationQuestion _question = CalculationQuestion.generate(20);

  AnimationController _controller;
  Animation<double> _animation;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextStyle bigNumberStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 70,
    color: Colors.black87,
  );

  void showCountDown() {
    Navigator.push(
      _scaffoldKey.currentState.context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return WaitScreen(winner: _lastWinner, users: _users);
        },
        fullscreenDialog: true,
      ),
    );
  }

  void showQuestionDirect(CalculationQuestion question) {
    setState(() {
      _question = question;
    });
  }

  void showQuestionAfterDelay(CalculationQuestion question) {
    showQuestionDirect(question);
    Navigator.pop(_scaffoldKey.currentState.context);
    setState(() {
      _monsterBottom = -10;
    });
    _controller.forward(from: 0);
  }

  void gotQuestion(CalculationQuestion question) {
    showCountDown();

    Future.delayed(
      Duration(milliseconds: 3500),
    ).then((o) => showQuestionAfterDelay(question));
  }

  void gotRound(Round round) {
    gotUser(round.winner);
    _lastWinner = round.winner.name;
    gotQuestion(round.next);
  }

  void gotUser(User user) {
    if (!_users.contains(user)) {
      List<User> allUsers = List<User>();
      allUsers.addAll(_users);
      allUsers.add(user);
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(user.name + ' joined'),
        ),
      );
      sendQuestion(_question);
      setState(() {
        _users = allUsers;
      });
    } else {
      var foundUser = _users.firstWhere((d) => d == user);
      if (foundUser != null) {
        setState(() {
          foundUser.score = user.score;
          foundUser.name = user.name;
        });
      }
    }
  }

  void setupSocket() async {
    await setupUdpListener(showQuestionDirect, gotRound, gotUser);
    var ip = await getIp();
    _me = User(ip, widget.name, 0);
    sendUser(_me);
  }

  void _gotAnswer(double answer) {
    var isCorrect = (answer == _question.correctResult);
    setState(() {
      _monsterBottom = isCorrect ? 0 : -70;
    });
    if (isCorrect) {
      sendRound(Round(
        _me.addWin(),
        1,
        CalculationQuestion.generate(20),
      ));
    } else {
      sendUser(_me.wrongAnswer());
    }
  }

  final Widget gubbe = new SvgPicture.asset(
    'assets/monster-short.svg',
    width: 156,
    height: 150,
  );

  @override
  void initState() {
    super.initState();
    setupSocket();
    _controller = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: new Interval(0, 1, curve: Curves.linear),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    disconnectSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   iconTheme: IconThemeData(color: Colors.black),
      //   elevation: 0,
      // ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 320,
            child: Material(
              color: Theme.of(context).accentColor,
              child: buildAnswers(_question.answers, _gotAnswer, context),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 300,
            child: Material(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              color: Colors.white,
              child: AnimatedBackground(
                behaviour: RandomParticleBehaviour(
                  options: ParticleOptions(
                    baseColor: Colors.green.shade400,
                    particleCount: 10,
                    spawnMaxRadius: 40,
                    spawnMaxSpeed: 100,
                    spawnMinSpeed: 10,
                    minOpacity: 0.03,
                    maxOpacity: 0.2,
                  ),
                ),
                vsync: this,
                child: Stack(
                  children: <Widget>[
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 300),
                      bottom: _monsterBottom,
                      left: 90,
                      right: 90,
                      height: 150,
                      child: gubbe,
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_question.firstNumber.toString(),
                                  style: bigNumberStyle),
                              Text(_question.modeChar, style: bigNumberStyle),
                              Text(_question.otherNumber.toString(),
                                  style: bigNumberStyle),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 18,
                      left: 10,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        iconSize: 30,
                        icon: Icon(Icons.arrow_back),
                      ),
                    ),
                    Positioned(
                      top: 45,
                      left: 0,
                      right: 0,
                      child: Hero(
                        tag: 'userlist',
                        child: Material(
                          elevation: 0,
                          color: Colors.transparent,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: UserList(users: _users),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // AnimatedPositioned(
          //   duration: Duration(milliseconds: 300),
          //   bottom: _monsterBottom,
          //   left: 90,
          //   right: 90,
          //   height: 150,
          //   child: gubbe,
          // ),
        ],
      ),
    );
  }
}
