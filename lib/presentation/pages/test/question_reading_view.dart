import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'package:speak_up/presentation/pages/lesson/lessonview.dart';

class TestQuestionReadingPage extends StatefulWidget {
  final String skillName;
  final String level;

  const TestQuestionReadingPage({
    Key? key,
    required this.skillName,
    required this.level,
  }) : super(key: key);

  @override
  _TestQuestionReadingPageState createState() =>
      _TestQuestionReadingPageState();
}

class _TestQuestionReadingPageState extends State<TestQuestionReadingPage> {
  final List<TextEditingController> _controllers =
      List.generate(7, (index) => TextEditingController());
  final List<String?> _selectedAnswers = List.filled(6, null);
  Timer? _timer;
  Duration _timeRemaining = Duration(minutes: 20);
  bool _isTestSubmitted = false;
  int _score = 0;

  final Map<int, String> correctAnswers = {
    0: 'B',
    1: 'C',
    2: 'F',
    3: 'D',
    4: 'E',
    5: 'A',
  };

  final Map<int, String> correctSummaryAnswers = {
    0: 'safety',
    1: 'traffic',
    2: 'road',
    3: 'mobile',
    4: 'dangerous',
    5: 'communities',
    6: 'efficient',
  };

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining.inSeconds > 0) {
          _timeRemaining = _timeRemaining - Duration(seconds: 1);
        } else {
          submitTest();
        }
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildTimerDisplay() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:
            _timeRemaining.inMinutes < 5 ? Colors.red[100] : Colors.blue[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: _timeRemaining.inMinutes < 5 ? Colors.red : Colors.blue,
          ),
          SizedBox(width: 8),
          Text(
            'Time remaining: ${_formatDuration(_timeRemaining)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _timeRemaining.inMinutes < 5 ? Colors.red : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCounter() {
    int totalQuestions = _selectedAnswers.length + _controllers.length;
    int answeredQuestions = _selectedAnswers
            .where((answer) => answer != null)
            .length +
        _controllers.where((controller) => controller.text.isNotEmpty).length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.question_answer, color: Colors.green),
          SizedBox(width: 8),
          Text(
            'Questions: $answeredQuestions/$totalQuestions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  void submitTest() {
    _timer?.cancel();
    int totalScore = 0;

    // Check multiple choice answers
    for (int i = 0; i < _selectedAnswers.length; i++) {
      if (_selectedAnswers[i] == correctAnswers[i]) {
        totalScore++;
      }
    }

    // Check summary completion answers
    for (int i = 0; i < _controllers.length; i++) {
      if (_controllers[i].text.toLowerCase().trim() ==
          correctSummaryAnswers[i]!.toLowerCase()) {
        totalScore++;
      }
    }

    setState(() {
      _isTestSubmitted = true;
      _score = totalScore;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _buildResultScreen()),
    );
  }

  Widget _buildResultScreen() {
    int totalQuestions = _selectedAnswers.length + _controllers.length;
    double percentage = (_score / totalQuestions) * 100;

    return Scaffold(
      appBar: AppBar(title: Text('Test Results')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Score Card
            Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Test Completed!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Your Score:',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '$_score/$totalQuestions',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: percentage >= 75
                            ? Colors.green
                            : percentage >= 50
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(fontSize: 24, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            // Multiple Choice Answers
            Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Multiple Choice Answers:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    ...List.generate(_selectedAnswers.length, (index) {
                      String userAnswer =
                          _selectedAnswers[index] ?? 'No answer';
                      String correctAnswer = correctAnswers[index]!;
                      bool isCorrect = userAnswer == correctAnswer;

                      return Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Question ${index + 1}',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                Text('Your answer: $userAnswer'),
                                SizedBox(width: 8),
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.cancel,
                                  color: isCorrect ? Colors.green : Colors.red,
                                  size: 16,
                                ),
                              ],
                            ),
                            Text('Correct answer: $correctAnswer',
                                style: TextStyle(color: Colors.green)),
                            Divider(),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            // Summary Completion Answers
            Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Summary Completion Answers:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    ...List.generate(_controllers.length, (index) {
                      String userAnswer =
                          _controllers[index].text.toLowerCase().trim();
                      String correctAnswer = correctSummaryAnswers[index]!;
                      bool isCorrect =
                          userAnswer == correctAnswer.toLowerCase();

                      return Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Question ${index + 7}',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                Text('Your answer: $userAnswer'),
                                SizedBox(width: 8),
                                Icon(
                                  isCorrect ? Icons.check_circle : Icons.cancel,
                                  color: isCorrect ? Colors.green : Colors.red,
                                  size: 16,
                                ),
                              ],
                            ),
                            Text('Correct answer: $correctAnswer',
                                style: TextStyle(color: Colors.green)),
                            Divider(),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LessonView1()));
              },
              child: Text('Back to Home'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildReadingPassage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "READING PASSAGE 1",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 8),
            Text(
              "Could urban engineers learn from dance?",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              "A. The way we travel around cities has a major impact on whether they are sustainable. Transportation is estimated to account for about 30% of energy consumption in most of the world’s most developed nations, so lowering the need for energy-using vehicles is essential for cities’ long-term environmental and economic stability. But as more and more people move to cities, it is important to think about other kinds of sustainable travel too. The ways we travel affect our physical and mental health, and as social lives, our access to work and culture, and more. Engineers are tasked with changing how we move around cities through urban design, but the engineering industry still works on the assumptions that led to the creation of the energy-consuming transport systems we have now, systems emphasised placed solely on efficiency, speed, and power, at the expense of trying to make travel healthier, more enjoyable, and less environmentally damaging to create and run cities.",
            ),
            SizedBox(height: 16),
            Text(
              "B. Dance might hold some of the answers. That is not to suggest everyone should dance their way to work, however healthy and happy it might make us, but rather that the techniques used by choreographers to experiment with ideas of movement in dance could provide engineers with tools to stimulate new ideas in city-making. Richard Sennett, an influential urbanist and sociologist who has transformed ideas about how cities are made, argues that urban design has suffered from a separation between mind and body since the introduction of the architectural blueprint.",
            ),
            SizedBox(height: 16),
            Text(
              "C. Whereas medieval builders improved and adapted construction through their intimate knowledge of materials and personal experience of the places they were building, modern designers have only considered in relation to the project at a distance, detached from the physical and social realities they are affecting. While the design process created by the blueprint encourages the overuse of managing materials rather than improving the way technologies are used in favor of making better cities.",
            ),
            SizedBox(height: 16),
            Text(
              "D. To illustrate, Sennett describes the Peachtree Center in Atlanta, USA, a pedestrian precinct designed to modernist principles by a prominent urban planner in the 1970s. Peachtree was a grid of streets and towers intended as a new pedestrian-friendly corridor away from Atlanta. According to Sennett, this failed because its designers had invested too much in traffic-free principles to tell them how it would operate. They failed to take into account that purpose-built street cafes could not operate in the hot sun without the protective awnings.",
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMultipleChoice() {
    final questions = [
      'reference to an appealing way of using dance that the writer is not proposing',
      'an example of a contrast between past and present approaches to building',
      'mention of an objective of both dance and engineering',
      'reference to an unforeseen problem arising from ignoring the climate',
      'why some measures intended to help people are being reversed',
      'reference to how transport has an impact on human lives',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.sp),
          child: Text(
            'Questions 1-6',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.sp),
          child: Text(
            'Reading Passage 1 has seven paragraphs, A-G.\nWhich paragraph contains the following information?',
            style: TextStyle(fontSize: 16.sp),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.all(8.sp),
              child: Padding(
                padding: EdgeInsets.all(16.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}. ${questions[index]}',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      children: ['A', 'B', 'C', 'D', 'E', 'F', 'G']
                          .map(
                            (option) => ChoiceChip(
                              label: Text(option),
                              selected: _selectedAnswers[index] == option,
                              onSelected: !_isTestSubmitted
                                  ? (selected) {
                                      setState(() {
                                        _selectedAnswers[index] =
                                            selected ? option : null;
                                      });
                                    }
                                  : null,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildSummaryCompletion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.sp),
          child: Text(
            'Questions 7-13',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Questions 1-6",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                "Reading Passage 1 has seven paragraphs, A-G.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                "Which paragraph contains the following information? Write the correct letter, A-G, in boxes 1-6 on your answer sheet.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                "1. reference to an appealing way of using dance that the writer is not proposing",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "2. an example of a contrast between past and present approaches to building",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "3. mention of an objective of both dance and engineering",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "4. reference to an unforeseen problem arising from ignoring the climate",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "5. why some measures intended to help people are being reversed",
                style: TextStyle(fontSize: 16),
              ),
              Text(
                "6. reference to how transport has an impact on human lives",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text(
                "Questions 7-13",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                "Complete the summary below. Choose ONE WORD ONLY from the passage for each answer. Write your answers in boxes 7-13 on your answer sheet.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                "Guard rails",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                "Guard rails were introduced on British roads to improve the 7. _______ of pedestrians, while ensuring that the movement of 8. _______ is not disrupted. Pedestrians are led to access points and encouraged to cross one 9. _______ at a time.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                "An unintended effect is to create psychological difficulties in crossing the road, particularly for less 10. _______ people. Another result is that some people cross the road in an 11. _______ way. The guard rails separate 12. _______ and make it more difficult to introduce forms of transport that are 13. _______.",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: 7,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.all(8.sp),
              child: TextField(
                controller: _controllers[index],
                decoration: InputDecoration(
                  labelText: 'Answer ${index + 7}',
                  border: OutlineInputBorder(),
                  enabled: !_isTestSubmitted,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IELTS Reading Test'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimerDisplay(),
                _buildQuestionCounter(),
              ],
            ),
            buildReadingPassage(),
            buildMultipleChoice(),
            buildSummaryCompletion(),
            Padding(
              padding: EdgeInsets.all(16.sp),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200.w, 50.h),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: !_isTestSubmitted ? submitTest : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline),
                    SizedBox(width: 8.w),
                    Text(
                      'Submit Test',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
