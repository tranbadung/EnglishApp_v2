import 'package:flutter/material.dart';
import 'package:speak_up/presentation/pages/ipa/ipa_view.dart';

class LessonView1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.grey),
                SizedBox(width: 5),
                Text('0', style: TextStyle(color: Colors.grey)),
              ],
            ),
            SizedBox(width: 10),
            Icon(Icons.account_circle, color: Colors.black)
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              tabs: [
                Tab(text: 'Khóa học'),
                Tab(text: 'Speak'),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                children: [
                  buildCoursesSection(),
                  IpaView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCoursesSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Khóa học phổ biến tuần qua',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 300,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                buildCourseCard('Thể hiện Cảm xúc', 'Spencer',
                    'assets/images/chatbot.png', 67131, 'Nhập môn · 8 ngày'),
                buildCourseCard(
                    'Tiếng Anh Thương mại Giao tiếp',
                    'Spencer',
                    'assets/images/chatbot.png',
                    66736,
                    'Trung cao cấp · 10 ngày'),
                // Thêm nhiều khóa học khác tại đây.
                buildCourseCard('Tiếng Anh Du lịch', 'Anna',
                    'assets/images/chatbot.png', 45000, 'Sơ cấp · 5 ngày'),
                buildCourseCard('Tiếng Anh Công nghệ', 'John',
                    'assets/images/chatbot.png', 58000, 'Trung cấp · 7 ngày'),
                buildCourseCard(
                    'Tiếng Anh cho Chuyên gia',
                    'Michael',
                    'assets/images/chatbot.png',
                    76000,
                    'Trung cao cấp · 12 ngày'),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Trình độ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          buildLevelFilterSection(),
        ],
      ),
    );
  }

  Widget buildCourseCard(String courseName, String instructor, String imageUrl,
      int views, String description) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  child: Image.asset(imageUrl,
                      fit: BoxFit.cover, width: double.infinity, height: 100),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.bookmark_border, color: Colors.white),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$views lượt xem',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 5),
                  Text(
                    instructor,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(courseName,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  Text(description, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLevelFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            buildLevelChip('Tất cả', true),

            // Thêm nhiều level khác nếu cần
          ],
        ),
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
          // Thực hiện hành động khi chọn level
        },
        selectedColor: Colors.black,
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
