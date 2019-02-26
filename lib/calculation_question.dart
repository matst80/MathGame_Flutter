import 'dart:math';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(nullable: false)
enum CalculationMode { add, sub, div, mul }

@JsonSerializable(nullable: false)
class CalculationQuestion {
  CalculationQuestion(CalculationMode mode, int first, int second) {
    firstNumber = first;
    otherNumber = second;
    this.mode = mode;
    switch (mode) {
      case CalculationMode.add:
        modeChar = ' + ';
        correctResult = (first + second).toDouble();
        break;
      case CalculationMode.sub:
        modeChar = ' - ';
        correctResult = (first - second).toDouble();
        break;
      case CalculationMode.div:
        modeChar = ' / ';
        correctResult = (first / second).toDouble();
        break;
      case CalculationMode.mul:
        modeChar = ' x ';
        correctResult = (first * second).toDouble();
        break;
      default:
    }
    answers = new List<double>();
    answers.add(correctResult);
    answers.add(getOtherAnswer());
    answers.add(getOtherAnswer());
    answers.add(getOtherAnswer());
  }

  double getOtherAnswer() {
    var rnd = Random();
    var maxNum =
        max((firstNumber * otherNumber) + 1, firstNumber + otherNumber + 1);
    var newNumber = rnd.nextInt(maxNum);
    while (answers.contains(newNumber.toDouble())) {
      newNumber = rnd.nextInt(maxNum);
    }
    return newNumber.toDouble();
  }

  String modeChar;
  int firstNumber;
  int otherNumber;
  CalculationMode mode;
  double correctResult;
  List<double> answers;

  factory CalculationQuestion.generate(int difficulty) =>
      _generateQuestion(difficulty);

  factory CalculationQuestion.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}

CalculationQuestion _$QuestionFromJson(Map<String, dynamic> json) {
  return CalculationQuestion(CalculationMode.values[json['mode'] as int],
      json['first'] as int, json['other'] as int);
}

Map<String, dynamic> _$QuestionToJson(CalculationQuestion instance) =>
    <String, dynamic>{
      'mode': instance.mode.index,
      'first': instance.firstNumber,
      'other': instance.otherNumber
    };

CalculationMode randomMode(Random rnd) {
  int pick = rnd.nextInt(CalculationMode.values.length);
  return CalculationMode.values[pick];
}

int getDivider(Random rnd, int f) {
  return (f ~/ rnd.nextInt(f - 2) + 1);
}

CalculationQuestion _generateQuestion(int difficulty) {
  var rnd = new Random();
  var mode = randomMode(rnd);
  if (mode == CalculationMode.div) {
    var f = rnd.nextInt(difficulty~/2) + 1;
    var f2 = rnd.nextInt(difficulty~/2) + 1;
    return CalculationQuestion(mode, f*f2, f2);
  }
  return CalculationQuestion(
      mode, rnd.nextInt(difficulty), rnd.nextInt(difficulty));
}
