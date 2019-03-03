import 'package:flutter/material.dart';
import 'user.dart';

class UserList extends StatefulWidget {
  UserList({Key key, this.users}) : super(key: key);

  final List<User> users;

  @override
  _UserList createState() => _UserList();
}

var userNameStyle = TextStyle(
  //color: Colors.white,
  fontWeight: FontWeight.bold,
);

// class _UserList extends State<UserList> {
//   @override
//   Widget build(BuildContext context) {
//     var userWidgets = widget.users
//         .map((user) => Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                   child: Text(
//                     user.name,
//                     style: userNameStyle,
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                   child: Chip(
//                     backgroundColor: Colors.black,
//                     labelStyle: TextStyle(color: Colors.white),
//                     label: Text(user.score.toString()),
//                   ),
//                 ),
//               ],
//             ))
//         .toList();
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: userWidgets,
//     );
//   }
// }

class _UserList extends State<UserList> {
  @override
  Widget build(BuildContext context) {
    var users = widget.users;
    users.sort((a, b) => a.score - b.score);
    var userWidgets = users
        .map(
          (user) => Chip(
                backgroundColor: Colors.black87,
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: userWidgets,
    );
  }
}
