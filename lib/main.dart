import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_screen.dart';
import 'package:flutter_svg/svg.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.white.withAlpha(50), 
    ));
    return MaterialApp(
      title: 'Math game',
      theme: ThemeData(
        primarySwatch: Colors.green,
        accentColor: Color.fromARGB(255, 45, 204, 113),
        brightness: Brightness.light,
      ),
      home: Onboarding(), 
    );
  }
}

class Onboarding extends StatefulWidget {
  @override
  _Onboarding createState() => _Onboarding();
}

class _Onboarding extends State<Onboarding> {
  final nameController = TextEditingController();

  SharedPreferences _prefs;

  final TextStyle loginStyle = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 16,
  );

  final TextStyle loginStyleInput = TextStyle(
    color: Colors.white
  );
  
  final TextStyle loginTitleStyle = TextStyle(
    fontWeight: FontWeight.normal,
    fontSize: 16,
    color: Colors.white,
  );

  final Widget svg = new SvgPicture.asset(
    'assets/star-white.svg',
    width: 100,
    height: 100,
  );

  final Widget gubbe = new SvgPicture.asset(
    'assets/monster-short.svg',
    width: 200,
  );

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void updatePrefs(SharedPreferences prefs) {
    _prefs = prefs;
    var nick = _prefs.getString("nick") ?? '';
    nameController.text = nick;
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then(updatePrefs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   elevation: 7,
      //   title: Text('Select nick'),
      // ),
      backgroundColor: Theme.of(context).accentColor,
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            height: 180,
            left: 0,
            right: 0,
            child: Center(
              child: gubbe,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 180,
            child: Container(
              padding: EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: svg,
                    padding: EdgeInsets.all(50),
                  ),
                  Text(
                    'Enter your name to start the game',
                    style: loginTitleStyle,
                  ),
                  SizedBox(height: 17),
                  TextField(
                    controller: nameController,
                    textAlign: TextAlign.center,
                    style: loginStyleInput,
                    autocorrect: true,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: 'Your nickname',
                      hintStyle: loginStyle,
                    ),
                  ),
                  SizedBox(height: 20),
                  RaisedButton(
                    color: Colors.white,
                    textColor: Theme.of(context).accentColor,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 35,
                        vertical: 14,
                      ),
                      child: Text(
                        'START GAME',
                        style: loginStyle,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    onPressed: () {
                      var nick = nameController.value.text;
                      _prefs.setString("nick", nick);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameScreen(
                                title: 'Player',
                                name: nick,
                              ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
