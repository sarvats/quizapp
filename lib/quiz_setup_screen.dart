import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'quiz_screen.dart';
import 'category.dart';

class QuizSetupScreen extends StatefulWidget {
  @override
  _QuizSetupScreenState createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  List<Category> categories = [];
  String? selectedCategory;
  String selectedDifficulty = 'easy';
  String selectedType = 'multiple';
  int numberOfQuestions = 5;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('https://opentdb.com/api_category.php'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        categories = (data['trivia_categories'] as List)
            .map((json) => Category.fromJson(json))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz Setup')),
      body: categories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    hint: Text('Select Category'),
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id.toString(),
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedCategory = value),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedDifficulty,
                    items: ['easy', 'medium', 'hard'].map((difficulty) {
                      return DropdownMenuItem(
                        value: difficulty,
                        child: Text(difficulty.capitalize()),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedDifficulty = value!),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: ['multiple', 'boolean'].map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.capitalize()),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedType = value!),
                  ),
                  Slider(
                    value: numberOfQuestions.toDouble(),
                    min: 5,
                    max: 20,
                    divisions: 3,
                    label: '$numberOfQuestions',
                    onChanged: (value) => setState(() => numberOfQuestions = value.toInt()),
                  ),
                  ElevatedButton(
                    onPressed: selectedCategory == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizScreen(
                                  category: selectedCategory!,
                                  difficulty: selectedDifficulty,
                                  type: selectedType,
                                  numberOfQuestions: numberOfQuestions,
                                ),
                              ),
                            );
                          },
                    child: Text('Start Quiz'),
                  ),
                ],
              ),
            ),
    );
  }
}

extension StringExtensions on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
