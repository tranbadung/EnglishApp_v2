import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speak_up/presentation/pages/test/question_liestening_view.dart';
import 'package:speak_up/presentation/pages/test/question_reading_view.dart';
import 'package:speak_up/presentation/pages/test/question_speaking_view%20copy.dart';
import 'package:speak_up/presentation/pages/test/question_writing_view%20.dart';

class SkillDetailPage extends StatefulWidget {
  final String skillName;

  const SkillDetailPage({required this.skillName, Key? key}) : super(key: key);

  @override
  _SkillDetailPageState createState() => _SkillDetailPageState();
}

class _SkillDetailPageState extends State<SkillDetailPage> {
  String selectedLevel = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.skillName} Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn cấp độ cho ${widget.skillName}:',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(20),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ScreenUtil().setHeight(20)),
            buildLevelFilterSection(),
            Spacer(),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedLevel.isEmpty
                      ? null
                      : () {
                          // Navigate to the test page if a level is selected
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StartTestPage(
                                skillName: widget.skillName,
                                level: selectedLevel,
                              ),
                            ),
                          );
                        },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Bắt đầu kiểm tra ${widget.skillName}',
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(18),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLevelFilterSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          buildLevelChip('Dễ', selectedLevel == 'Easy'),
          buildLevelChip('Trung bình', selectedLevel == 'Medium'),
          buildLevelChip('Khó', selectedLevel == 'Hard'),
        ],
      ),
    );
  }

  Widget buildLevelChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            selectedLevel = selected ? label : '';
          });
        },
        selectedColor: Colors.blueAccent,
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

class StartTestPage extends StatelessWidget {
  final String skillName;
  final String level;

  const StartTestPage({required this.skillName, required this.level, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bắt đầu kiểm tra $skillName'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Kiểm tra $skillName - cấp độ $level',
              style: TextStyle(
                fontSize: ScreenUtil().setSp(22),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ScreenUtil().setHeight(20)),
            ElevatedButton(
              onPressed: () {
                // Điều hướng đến trang câu hỏi
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      if (skillName == 'Listening') {
                        return TestQuestionlisteningPage(
                            skillName: skillName, level: level);
                      } else if (skillName == 'Reading') {
                        return TestQuestionReadingPage(
                            skillName: skillName, level: level);
                      } else if (skillName == 'Speaking') {
                        return TestQuestionspeakingPage(
                            skillName: skillName, level: level);
                      } else {
                        return TestQuestionwritingPage(
                            skillName: skillName, level: level);
                      }
                    },
                  ),
                );
              },
              child: Text('Bắt đầu kiểm tra ngay'),
            ),
          ],
        ),
      ),
    );
  }
}
