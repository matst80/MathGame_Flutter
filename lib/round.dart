import 'package:json_annotation/json_annotation.dart';
import 'user.dart';
import 'calculation_question.dart';

@JsonSerializable(nullable: false)
class Round {
  Round(User user, double elapsedTime, CalculationQuestion nextQuestion) {
    this.winner = user;
    this.time = elapsedTime;
    this.next = nextQuestion;
  }
  User winner;
  double time;
  CalculationQuestion next;

  factory Round.fromJson(Map<String, dynamic> json) => _$RoundFromJson(json);
  Map<String, dynamic> toJson() => _$RoundToJson(this);
}

Round _$RoundFromJson(Map<String, dynamic> json) {
  return Round(User.fromJson(json['winner']), json['time'] as double,
      CalculationQuestion.fromJson(json['next']));
}

Map<String, dynamic> _$RoundToJson(Round instance) => <String, dynamic>{
      'winner': instance.winner.toJson(),
      'time': instance.time,
      'next': instance.next
    };
