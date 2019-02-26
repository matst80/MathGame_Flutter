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
        (answer) => ActionChip(
              backgroundColor: Colors.blue,
              onPressed: () => onAnswer(answer),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              labelStyle: numberStyle,
              key: Key(answer.toString()),
              label: Text(answer.toInt().toString()),
              // child: SizedBox(
              //   width: 100,
              //   height: 100,
              //   child: Center(
              //     child: Text(answer.toInt().toString(), style: numberStyle),
              //   ),
              // ),
            ),
      )
      .toList());
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Wrap(
      spacing: 18,
      runSpacing: 18,
      children: answerWidgets,
    ),
  );
}

var numberStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 50);
var bigNumberStyle = TextStyle(fontWeight: FontWeight.normal, fontSize: 70);

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  //double _questionOpacity = 1;
  List<User> _users = List<User>();
  String _lastWinner = '';
  User _me;

  CalculationQuestion _question =
      CalculationQuestion(CalculationMode.add, 3, 4);

  AnimationController _controller;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const int kStartValue = 4;

  void _showBottomSheet() {
    showModalBottomSheet<void>(
        context: _scaffoldKey.currentState.context,
        builder: (BuildContext context) {
          return Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Winner: $_lastWinner',
                    style: numberStyle,
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
        });
  }

  void gotQuestion(CalculationQuestion question) {
    _controller.forward(from: 0.0);
    _showBottomSheet();

    Future.delayed(Duration(milliseconds: 3500)).then((o) => setState(() {
          _question = question;
        }));
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
    if (state == AnimationStatus.completed) {
      Navigator.pop(_scaffoldKey.currentState.context);
    }
  }

  @override
  void initState() {
    super.initState();
    setupSocket();
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
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title + ' - ' + widget.name),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildUsers(_users),
          SizedBox(height: 30),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(_question.firstNumber.toString(), style: bigNumberStyle),
            Text(_question.modeChar, style: bigNumberStyle),
            Text(_question.otherNumber.toString(), style: bigNumberStyle),
          ]),
          Container(
            color: Colors.tealAccent,
            child: buildAnswers(_question.answers, _gotAnswer),
          ),
        ],
      ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => {},
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ),
    );
  }
}
