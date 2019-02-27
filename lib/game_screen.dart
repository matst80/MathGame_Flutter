import 'package:flutter/material.dart';
import 'calculation_question.dart';
import 'utils.dart';
import 'network_helper.dart';
import 'countdown.dart';
import 'round.dart';
import 'user.dart';
import 'userlist.dart';

typedef void AnswerPressed(double answer);

Widget buildAnswers(List<double> answers, AnswerPressed onAnswer) {
  var answerWidgets = shuffle(answers
      .map(
        (answer) => ActionChip(
              backgroundColor: Colors.black,
              onPressed: () => onAnswer(answer),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              labelStyle: numberStyle,
              key: Key(answer.toString()),
              label: Text(answer.toInt().toString()),
            ),
      )
      .toList());
  return Padding(
    padding: const EdgeInsets.all(32.0),
    child: Wrap(
      spacing: 18,
      alignment: WrapAlignment.center,
      runSpacing: 18,
      children: answerWidgets,
    ),
  );
}

var numberStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 50,
);
var bigNumberStyle = TextStyle(
  fontWeight: FontWeight.normal,
  fontSize: 70,
  color: Colors.white,
  shadows: <Shadow>[
    Shadow(
      offset: Offset(3.0, 3.0),
      blurRadius: 9.0,
      color: Color.fromARGB(190, 0, 0, 0),
    )
  ],
);

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

  CalculationQuestion _question =
      CalculationQuestion(CalculationMode.add, 3, 4);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showBottomSheet() {
    Navigator.push(
        _scaffoldKey.currentState.context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return WaitScreen(winner: _lastWinner, users: _users);
          },
          fullscreenDialog: true,
        ));
  }

  void showNewQuestion(CalculationQuestion question) {
    setState(() {
      _question = question;
    });
    Navigator.pop(_scaffoldKey.currentState.context);
  }

  void gotQuestion(CalculationQuestion question) {
    _showBottomSheet();

    Future.delayed(Duration(
      milliseconds: 3500,
    )).then((o) => showNewQuestion(question));
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

  @override
  void initState() {
    super.initState();
    setupSocket();
  }

  void _gotAnswer(double answer) {
    var isCorrect = (answer == _question.correctResult);

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
        elevation: 2,
        title: Text(widget.title + ' - ' + widget.name),
      ),
      backgroundColor: Colors.green.shade700,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Hero(
            tag: 'userlist',
            child: Material(
              elevation: 4,
              color: Colors.green.shade600,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: UserList(users: _users),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_question.firstNumber.toString(), style: bigNumberStyle),
              Text(_question.modeChar, style: bigNumberStyle),
              Text(_question.otherNumber.toString(), style: bigNumberStyle),
            ],
          ),
          Material(
            color: Colors.green,
            elevation: 4,
            child: Center(
              child: buildAnswers(_question.answers, _gotAnswer),
            ),
          ),
        ],
      ),
    );
  }
}
