import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class WritingResultScreen extends StatefulWidget {
  final String feedback1;
  final String feedback2;
  final int wordCount1;
  final int wordCount2;

  const WritingResultScreen({
    Key? key,
    required this.feedback1,
    required this.feedback2,
    required this.wordCount1,
    required this.wordCount2,
  }) : super(key: key);

  @override
  _WritingResultScreenState createState() => _WritingResultScreenState();
}

class _WritingResultScreenState extends State<WritingResultScreen> {
  double overallScore = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateAndSaveOverallScore();
  }

  Future<void> saveOverallScore(double overallScore) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('writingScore', overallScore);
    // await WritingScoreHandler.saveWritingScore(overallScore);
    print('Saving writing band score: $overallScore');
  }

  // Calculate and save overall score once
  Future<void> _calculateAndSaveOverallScore() async {
    final task1Results = _parseGPTFeedback(widget.feedback1);
    final task2Results = _parseGPTFeedback(widget.feedback2);

    overallScore = ((task1Results['score'] + task2Results['score']) / 2);

    await saveOverallScore(overallScore);
    setState(() {});
  }

  // Parsing feedback
  Map<String, dynamic> _parseGPTFeedback(String feedback) {
    RegExp scoreRegex = RegExp(r'(?:Band Score:|Score:)\s*(\d+\.?\d*)');
    var scoreMatch = scoreRegex.firstMatch(feedback);
    double score =
        scoreMatch != null ? double.parse(scoreMatch.group(1) ?? "0.0") : 0.0;

    return {
      'score': score,
      'feedback': feedback,
      'criteriaScores': _extractCriteriaScores(feedback),
    };
  }

  Map<String, double> _extractCriteriaScores(String feedback) {
    Map<String, double> scores = {
      'Task Achievement': 0.0,
      'Coherence and Cohesion': 0.0,
      'Lexical Resource': 0.0,
      'Grammatical Range': 0.0,
    };

    for (var criterion in scores.keys) {
      RegExp regex = RegExp('$criterion:?\\s*(\\d+(?:\\.\\d+)?)');
      var match = regex.firstMatch(feedback);
      if (match != null) {
        scores[criterion] = double.parse(match.group(1) ?? "0.0");
      }
    }

    return scores;
  }

  @override
  Widget build(BuildContext context) {
    // This widget now updates after overallScore is calculated and saved
    final task1Results = _parseGPTFeedback(widget.feedback1);
    final task2Results = _parseGPTFeedback(widget.feedback2);

    return Scaffold(
      appBar: AppBar(
        title: Text('IELTS Writing Results'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.blue[50],
              child: Column(
                children: [
                  Text(
                    'Overall Band Score',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildScoreCard('Task 1', task1Results['score']),
                      _buildScoreCard('Task 2', task2Results['score']),
                      _buildScoreCard('Overall', overallScore),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Word Count: Task 1: ${widget.wordCount1}/150 | Task 2: ${widget.wordCount2}/250',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
            _buildCriteriaSection(
              'Task 1 Criteria Scores',
              task1Results['criteriaScores'],
            ),
            _buildFeedbackSection('Task 1 Feedback', task1Results['feedback']),
            _buildCriteriaSection(
              'Task 2 Criteria Scores',
              task2Results['criteriaScores'],
            ),
            _buildFeedbackSection('Task 2 Feedback', task2Results['feedback']),
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.popUntil(
                        context,
                        ModalRoute.withName('/main_menu'),
                      );
                    },
                    icon: Icon(Icons.home),
                    label: Text('Back to Home'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(String title, double score) {
    return Card(
      elevation: 2,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getScoreColor(score),
              ),
              child: Center(
                child: Text(
                  score.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 7.0) return Colors.green;
    if (score >= 6.0) return Colors.blue;
    if (score >= 5.0) return Colors.orange;
    return Colors.red;
  }

  Widget _buildCriteriaSection(String title, Map<String, double> scores) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 16),
            ...scores.entries
                .map((entry) => Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: entry.value / 9,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getScoreColor(entry.value),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            entry.value.toStringAsFixed(1),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(entry.value),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(String title, String feedback) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 16),
            Text(
              feedback,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
