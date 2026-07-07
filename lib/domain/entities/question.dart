class Question {
  final String equation;
  final int answer;
  final String operator;
  final int operand1;
  final int operand2;
  final String difficulty;

  const Question({
    required this.equation,
    required this.answer,
    required this.operator,
    required this.operand1,
    required this.operand2,
    required this.difficulty,
  });
}
