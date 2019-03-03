import 'package:flutter/material.dart';
import 'user.dart';

class UserList extends StatefulWidget {
  UserList({Key key, this.users}) : super(key: key);

  final List<User> users;

  @override
  _UserList createState() => _UserList();
}

class UserListOverview extends StatefulWidget {
  UserListOverview({Key key, this.users}) : super(key: key);

  final List<User> users;

  @override
  _UserListOverview createState() => _UserListOverview();
}

var userNameStyle = TextStyle(
  //color: Colors.white,
  fontWeight: FontWeight.bold,
);

class _UserListOverview extends State<UserListOverview> {
  @override
  Widget build(BuildContext context) {
    var userWidgets = widget.users
        .map(
          (user) => Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1, color: Colors.black38),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                      child: Text(
                        user.name,
                        style: userNameStyle,
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                      child: Chip(
                        backgroundColor: Colors.black,
                        labelStyle: TextStyle(color: Colors.white),
                        label: Text(user.score.toString()),
                      ),
                    ),
                  ],
                ),
              ),
        )
        .toList();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: userWidgets,
    );
  }
}

class _UserList extends State<UserList> {
  @override
  Widget build(BuildContext context) {
    var users = widget.users;
    users.sort((a, b) => b.score - a.score);
    var idx = 1;
    var userWidgets = users
        .map(
          (user) => Chip(
                backgroundColor: idx++ == 1
                    ? Theme.of(context).primaryColor
                    : Colors.black87,
                labelStyle: TextStyle(color: Colors.white),
                label: Text.rich(
                  TextSpan(
                    text: user.name, // default text style
                    children: <TextSpan>[
                      TextSpan(
                          text: ' ' + user.score.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
        )
        .toList();
    return Center(
      child: Wrap(
        runAlignment: WrapAlignment.center,
        spacing: 4,
        runSpacing: 4,
        //mainAxisAlignment: MainAxisAlignment.start,
        children: userWidgets,
      ),
    );
  }
}
