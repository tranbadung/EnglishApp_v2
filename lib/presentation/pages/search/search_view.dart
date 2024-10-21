// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:speak_up/domain/entities/lesson/lesson.dart';

// class SearchPage extends ConsumerStatefulWidget {
//   const SearchPage({super.key});

//   @override
//   ConsumerState<SearchPage> createState() => _SearchPageState();
// }

// class _SearchPageState extends ConsumerState<SearchPage> {
//   // Controller cho ô tìm kiếm
//   final TextEditingController _searchController = TextEditingController();
//   // Danh sách chứa các bài học đã lọc
//   List<Lesson> _filteredLessons = [];

//   @override
//   void initState() {
//     super.initState();
//     // Khởi tạo với danh sách bài học ban đầu (tất cả các bài học)
//     _filteredLessons = lessonWidgetList.values.toList();
//   }

//   // Hàm lọc danh sách bài học dựa trên từ khóa tìm kiếm
//   void _searchLessons(String query) {
//     setState(() {
//       // Nếu từ khóa rỗng, hiển thị tất cả bài học
//       if (query.isEmpty) {
//         _filteredLessons = lessonWidgetList.values.toList();
//       } else {
//         // Lọc danh sách bài học
//         _filteredLessons = lessonWidgetList.values
//             .where((lesson) =>
//                 lesson.name.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: TextField(
//           controller: _searchController,
//           decoration: InputDecoration(
//             hintText: 'Search lessons...',
//             border: InputBorder.none,
//           ),
//           // Gọi hàm tìm kiếm khi có thay đổi trong ô tìm kiếm
//           onChanged: _searchLessons,
//         ),
//       ),
//       body: _filteredLessons.isNotEmpty
//           ? ListView.builder(
//               itemCount: _filteredLessons.length,
//               itemBuilder: (context, index) {
//                 final lesson = _filteredLessons[index];
//                 return ListTile(
//                   title: Text(lesson.name),
//                   subtitle: Text(lesson.description),
//                   leading: Image.asset(lesson.imageURL),
//                   onTap: () {
//                     // Điều hướng tới trang chi tiết bài học khi người dùng chọn bài học
//                     Navigator.pushNamed(
//                       context,
//                       '/lesson',
//                       arguments: lesson,
//                     );
//                   },
//                 );
//               },
//             )
//           : Center(
//               child: Text('No lessons found'),
//             ),
//     );
//   }
// }
