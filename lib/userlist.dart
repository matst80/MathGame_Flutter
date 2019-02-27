import 'package:flutter/material.dart';
import 'user.dart';

class UserList extends StatefulWidget {
  UserList({Key key, this.users}) : super(key: key);

  final List<User> users;

  @override
  _UserList createState() => _UserList();
}

var userNameStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
);

class _UserList extends State<UserList> {
  @override
  Widget build(BuildContext context) {
    var userWidgets = widget.users
        .map((user) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    user.name,
                    style: userNameStyle,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Chip(
                    label: Text(user.score.toString()),
                  ),
                ),
              ],
            ))
        .toList();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: userWidgets,
    );
  }
}
