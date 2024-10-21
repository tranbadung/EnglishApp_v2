import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';

class TestQuestionPage extends StatefulWidget {
  final String skillName;
  final String level;

  const TestQuestionPage(
      {required this.skillName, required this.level, Key? key})
      : super(key: key);

  @override
  _TestQuestionPageState createState() => _TestQuestionPageState();
}

class _TestQuestionPageState extends State<TestQuestionPage> {
  List<Map<String, dynamic>> testQuestions = [
    {
      'question': 'Address of agency: 497 Eastside, Docklands',
      'blank': false,
    },
    {
      'question': 'Name of agent: Becky ',
      'blank': true,
      'answer': '',
      'hint': 'Write ONE WORD',
    },
    {
      'question': 'Best to call her in the ',
      'blank': true,
      'answer': '',
      'hint': 'Write ONE WORD OR A NUMBER',
    },
    {
      'question': 'Clerical and admin roles, mainly in the finance industry',
      'blank': false,
    },
    // Các câu hỏi khác...
  ];
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer(); // Khởi tạo _audioPlayer
    _initAudio();
  }

  Future<void> _initAudio() async {
    await _audioPlayer.setUrl('https://www.example.com/audio.mp3');
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Hủy _audioPlayer khi không sử dụng nữa
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listening Test'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildAudioPlayer(), // Thêm Audio Player vào đầu trang
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: testQuestions.length,
                itemBuilder: (context, index) {
                  return buildQuestionCard(testQuestions[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAudioPlayer() {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Audio Instructions',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(18),
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: () => _audioPlayer.play(),
                ),
                IconButton(
                  icon: Icon(Icons.pause),
                  onPressed: () => _audioPlayer.pause(),
                ),
                IconButton(
                  icon: Icon(Icons.stop),
                  onPressed: () => _audioPlayer.stop(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQuestionCard(Map<String, dynamic> questionData) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!questionData['blank'])
              Text(
                questionData['question'],
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(18),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            if (questionData['blank'])
              Row(
                children: [
                  Expanded(
                    child: Text(
                      questionData['question'],
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(18),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: questionData['hint'],
                        hintStyle: TextStyle(
                          fontSize: ScreenUtil().setSp(16),
                          color: Colors.grey[600],
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          questionData['answer'] = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
