import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_screen.dart';

void main() => runApp(MyApp());

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
        title: Text('Select nick'),
      ),
      body: Container(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: 'Your nickname'),
            ),
            RaisedButton(
              child: Text('Start'),
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
