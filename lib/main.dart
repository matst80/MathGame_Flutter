import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_screen.dart';

void main() => runApp(MyApp());

var loginStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 30);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math game',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Onboarding(), //MyHomePage(title: 'Calculus game'),
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
      appBar: AppBar(
        elevation: 7,
        title: Text('Select nick'),
      ),
      backgroundColor: Colors.green.shade600,
      body: Container(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              style: loginStyle,
              autocorrect: true,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(hintText: 'Your nickname'),
            ),
            SizedBox(height: 30),
            OutlineButton(
              textColor: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'STARTA',
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
    );
  }
}
