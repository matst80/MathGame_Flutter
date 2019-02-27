import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(nullable: false)
class User {
  User(String ip, String name, int score) {
    this.ip = ip;
    this.name = name;
    this.score = score;
  }
  int score;
  String ip;
  String name;
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User addWin() {
    score++;
    return this;
  }

  bool operator ==(o) => o is User && o.ip == ip;

  @override
  int get hashCode {
    return ip.hashCode;
  }

  User wrongAnswer() {
    score--;
    return this;
  }
}

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    json['ip'] as String,
    json['name'] as String,
    json['score'] as int,
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'ip': instance.ip,
      'name': instance.name,
      'score': instance.score
    };
