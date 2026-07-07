import 'dart:math';

import 'package:mental_math_marathon/domain/entities/question.dart';
import 'package:mental_math_marathon/models/game_config.dart';

class GenerateQuestion {
  final Random _random = Random();

  Question call(GameConfig config) {
    final maxRange = switch (config.difficulty) {
      'easy' => 20,
      'medium' => 100,
      'hard' => 500,
      _ => 20,
    };

    final String op = _pickOperator(config.operators);

    if (op == '÷') return _generateDivision(maxRange, config.difficulty);

    final int a = _random.nextInt(maxRange) + 1;
    final int b = _random.nextInt(maxRange) + 1;

    final operand1 = (op == '-') ? max(a, b) : a;
    final operand2 = (op == '-') ? min(a, b) : b;

    final int answer = _calculate(operand1, operand2, op);

    return Question(
      equation: '$operand1 $op $operand2',
      answer: answer,
      operator: op,
      operand1: operand1,
      operand2: operand2,
      difficulty: config.difficulty,
    );
  }

  Question _generateDivision(int maxRange, String difficulty) {
    final int divisor = _random.nextInt(max(2, maxRange ~/ 5)) + 1;
    final int quotient = _random.nextInt(maxRange) + 1;
    final int dividend = divisor * quotient;
    return Question(
      equation: '$dividend ÷ $divisor',
      answer: quotient,
      operator: '÷',
      operand1: dividend,
      operand2: divisor,
      difficulty: difficulty,
    );
  }

  String _pickOperator(List<String> operators) {
    if (operators.isEmpty) return '+';
    return operators[_random.nextInt(operators.length)];
  }

  int _calculate(int a, int b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        return a ~/ b;
      default:
        return a + b;
    }
  }
}
