import 'package:flutter/material.dart';
import 'calculation_question.dart';
import 'utils.dart';
import 'network_helper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Calculus game'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

typedef void AnswerPressed(double answer);

Widget buildAnswers(List<double> answers, AnswerPressed onAnswer) {
  var answerWidgets = shuffle(answers
      .map((answer) => RaisedButton(
          color: Colors.deepOrange,
          onPressed: () => onAnswer(answer),
          key: Key(answer.toString()),
          child: SizedBox(
              width: 100,
              height: 100,
              child: Center(
                  child: Text(answer.toInt().toString(), style: numberStyle)))))
      .toList());
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: answerWidgets,
  );
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

var numberStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 50);

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _counter = 0;
  double _questionOpacity = 1;

  String volitileTitle = 'Question';
  CalculationQuestion _question =
      CalculationQuestion(CalculationMode.add, 3, 4);

  AnimationController _controller;

  static const int kStartValue = 4;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void gotQuestion(CalculationQuestion question) {
    _controller.forward(from: 0.0);
    setState(() {
      _question = question;
    });
  }

  void setupSocket() async {
    await setupUdpListener(gotQuestion);
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
      sendQuestion(stateQuestion);
    } else {
      setState(() {
        _question = stateQuestion;
        //volitileTitle = isCorrect ? 'Correct' : 'Wrong';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(volitileTitle),
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
                      ])))),
          Positioned.fill(
              child: new Opacity(
                  opacity: 1 - _questionOpacity,
                  child: Center(
                      child: Countdown(
                    animation: new StepTween(
                      begin: kStartValue,
                      end: 1,
                    ).animate(_controller),
                  )))),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
