import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'question.dart';
import 'quiz_summary_screen.dart';

class QuizScreen extends StatefulWidget {
  final String category;
  final String difficulty;
  final String type;
  final int numberOfQuestions;

  QuizScreen({
    required this.category,
    required this.difficulty,
    required this.type,
    required this.numberOfQuestions,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool isLoading = true;
  bool isAnswered = false;
  Timer? timer;
  int remainingTime = 15;
  String? selectedAnswer; 

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final url =
        'https://opentdb.com/api.php?amount=${widget.numberOfQuestions}&category=${widget.category}&difficulty=${widget.difficulty}&type=${widget.type}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        questions = (data['results'] as List)
            .map((json) => Question.fromJson(json))
            .toList();
        isLoading = false;
        startTimer();
      });
    }
  }

  void startTimer() {
    timer?.cancel();
    setState(() {
      remainingTime = 15;
    });
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          timer.cancel();
          handleAnswer(null); // Timeout
        }
      });
    });
  }

   void handleAnswer(String? selected) {
    timer?.cancel();
    setState(() {
      selectedAnswer = selected; // Store the selected answer
      isAnswered = true;
    });

    if (selected == questions[currentQuestionIndex].correctAnswer) {
      setState(() {
        score++;
      });
    }

    Future.delayed(Duration(seconds: 2), () {
      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          isAnswered = false;
          selectedAnswer = null; // Reset selected answer
        });
        startTimer();
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizSummaryScreen(
              totalScore: score,
              questions: questions,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Quiz')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${currentQuestionIndex + 1} / ${questions.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
            ),
            SizedBox(height: 16),
            Text(
              'Time Remaining: $remainingTime seconds',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              question.question,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            ...question.answers.map((answer) {
              return ElevatedButton(
                onPressed: isAnswered ? null : () => handleAnswer(answer),
                child: Text(answer),
              );
            }).toList(),
            if (isAnswered)
              Text(
                selectedAnswer == question.correctAnswer
                    ? "Correct!"
                    : "Incorrect! Correct Answer: ${question.correctAnswer}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
