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
                    style: numberStyle,
                  ),
                ),
              ),
            ),
      )
      .toList());
  return Padding(
    padding: const EdgeInsets.fromLTRB(
      22,
      50,
      22,
      50,
    ),
    child: Wrap(
      spacing: 45,
      alignment: WrapAlignment.center,
      runSpacing: 25,
      children: answerWidgets,
    ),
  );
}

var numberStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 40,
  color: Colors.green.shade400,
);

var bigNumberStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 70,
  color: Colors.green.shade400,
  // shadows: <Shadow>[
  //   Shadow(
  //     offset: Offset(3.0, 3.0),
  //     blurRadius: 9.0,
  //     color: Color.fromARGB(100, 0, 0, 0),
  //   )
  // ],
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

  void showCountDown() {
    Navigator.push(
        _scaffoldKey.currentState.context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) {
            return WaitScreen(winner: _lastWinner, users: _users);
          },
          fullscreenDialog: true,
        ));
  }

  void showQuestionDirect(CalculationQuestion question) {
    setState(() {
      _question = question;
    });
  }

  void showNewQuestion(CalculationQuestion question) {
    setState(() {
      _question = question;
    });
    Navigator.pop(_scaffoldKey.currentState.context);
  }

  void gotQuestion(CalculationQuestion question) {
    showCountDown();

    Future.delayed(
      Duration(
        milliseconds: 3500,
      ),
    ).then((o) => showNewQuestion(question));
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
  void initState() {
    super.initState();
    setupSocket();
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
        backgroundColor: Colors.white,
        
        iconTheme: IconThemeData(
          color: Colors.black
        ),
        elevation: 0,
        //title: Text(widget.title + ' - ' + widget.name),
      ),
      // floatingActionButton: IconButton(
      //   icon: Icon(Icons.close),
      //   onPressed: () => Navigator.pop(context),
      // ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.,
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Hero(
            tag: 'userlist',
            child: Material(
              elevation: 0,
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal:16, vertical: 4),
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
          // Material(
          //   color: Colors.white,
          //   borderRadius: BorderRadius.circular(20),
          //   child: SizedBox(
          //     height: 30,
          //   ),
          // ),
          Material(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            color: Colors.green.shade400,
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
