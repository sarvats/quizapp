import 'package:html/parser.dart';

class Question {
  final String question;
  final List<String> answers;
  final String correctAnswer;

  Question({required this.question, required this.answers, required this.correctAnswer});

factory Question.fromJson(Map<String, dynamic> json) {
  final incorrectAnswers = (json['incorrect_answers'] as List<dynamic>)
      .map((answer) => answer as String)
      .toList();
  final correctAnswer = json['correct_answer'] as String;

  final decodedQuestion = parse(json['question']).body?.text ?? json['question'];
  
  final answers = [...incorrectAnswers, correctAnswer]..shuffle();

  return Question(
    question: decodedQuestion, 
    answers: answers,
    correctAnswer: correctAnswer,
  );
}
}

