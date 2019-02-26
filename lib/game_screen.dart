import 'package:flutter/material.dart';
import 'calculation_question.dart';
import 'utils.dart';
import 'network_helper.dart';
import 'countdown.dart';
import 'user.dart';
import 'round.dart';

class GameScreen extends StatefulWidget {
  GameScreen({Key key, this.title, this.name}) : super(key: key);

  final String title;
  final String name;

  @override
  _GameScreenState createState() => _GameScreenState();
}

typedef void AnswerPressed(double answer);

Widget buildUsers(List<User> users) {
  var userWidgets = users
      .map((user) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(user.name),
              Text(user.score.toString()),
            ],
          ))
      .toList();
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: userWidgets,
  );
}

Widget buildAnswers(List<double> answers, AnswerPressed onAnswer) {
  var answerWidgets = shuffle(answers
      .map(
        (answer) => RaisedButton(
              color: Colors.blue,
              onPressed: () => onAnswer(answer),
              key: Key(answer.toString()),
              child: SizedBox(
                width: 100,
                height: 100,
                child: Center(
                  child: Text(answer.toInt().toString(), style: numberStyle),
                ),
              ),
            ),
      )
      .toList());
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: answerWidgets,
  );
}

var numberStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 50);

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  double _questionOpacity = 1;
  List<User> _users = List<User>();
  String _lastWinner = '';
  User _me;

  CalculationQuestion _question =
      CalculationQuestion(CalculationMode.add, 3, 4);

  AnimationController _controller;

  static const int kStartValue = 4;

  void gotQuestion(CalculationQuestion question) {
    _controller.forward(from: 0.0);
    setState(() {
      _question = question;
    });
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
    await setupUdpListener(gotQuestion, gotRound, gotUser);
    var ip = await getIp();
    _me = User(ip, widget.name, 0);
    sendUser(_me);
  }

  void handleState(state) {
    setState(() {
      _questionOpacity = state == AnimationStatus.completed ? 1 : 0;
    });
  }

  @override
  void initState() {
    setupSocket();
    super.initState();
    _controller = new AnimationController(
      duration: new Duration(seconds: kStartValue),
      vsync: this,
    );
    _controller.addStatusListener((state) => handleState(state));
  }

  void _gotAnswer(double answer) {
    var isCorrect = (answer == _question.correctResult);
    var stateQuestion =
        isCorrect ? CalculationQuestion.generate(20) : _question;

    if (isCorrect) {
      sendRound(Round(_me.addWin(), 1, stateQuestion));
      //sendQuestion(stateQuestion);
    } else {
      setState(() {
        _question = stateQuestion;
        //volitileTitle = isCorrect ? 'Correct' : 'Wrong';
      });
    }
  }

  @override
  void dispose() {
    disconnectSocket();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title + ' - ' + widget.name),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: _questionOpacity,
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildUsers(_users),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_question.firstNumber.toString(),
                                style: numberStyle),
                            Text(_question.modeChar, style: numberStyle),
                            Text(_question.otherNumber.toString(),
                                style: numberStyle),
                          ]),
                      buildAnswers(_question.answers, _gotAnswer),
                    ]),
              ),
            ),
          ),
          Positioned.fill(
            child: new Opacity(
              opacity: 1 - _questionOpacity,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Winner: $_lastWinner'),
                    Countdown(
                      animation: new StepTween(
                        begin: kStartValue,
                        end: 1,
                      ).animate(_controller),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ),
    );
  }
}
