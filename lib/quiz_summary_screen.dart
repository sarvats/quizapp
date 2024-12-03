import 'package:flutter/material.dart';
import 'question.dart';

class QuizSummaryScreen extends StatelessWidget {
  final int totalScore;
  final List<Question> questions;

  

  QuizSummaryScreen({required this.totalScore, required this.questions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Your Score: $totalScore / ${questions.length}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return ListTile(
                    title: Text(question.question),
                    subtitle: Text('Correct Answer: ${question.correctAnswer}'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text('Return to Setup'),
            ),
          ],
        ),
      ),
    );
  }
}
