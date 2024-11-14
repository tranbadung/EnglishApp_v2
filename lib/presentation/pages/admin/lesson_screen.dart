import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class LessonListScreen extends StatefulWidget {
  @override
  _LessonListScreenState createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  bool isLoading = false;
  List<Map<String, dynamic>> lessons = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String lessonCollection = 'Lesson';

  @override
  void initState() {
    super.initState();
    fetchLessons();
  }

  Future<void> fetchLessons() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot snapshot = await _firestore.collection(lessonCollection).get();
      setState(() {
        lessons = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching lessons: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void showAddEditDialog({Map<String, dynamic>? lesson}) {
    final isEditing = lesson != null;
    final TextEditingController nameController = TextEditingController(text: lesson?['Name'] ?? '');
    final TextEditingController descriptionController = TextEditingController(text: lesson?['Description'] ?? '');
    final TextEditingController descriptionTranslationController = TextEditingController(text: lesson?['DescriptionTranslation'] ?? '');
    final TextEditingController imageURLController = TextEditingController(text: lesson?['ImageURL'] ?? '');
    final TextEditingController lessonIDController = TextEditingController(text: lesson?['LessonID'] ?? '');
    final TextEditingController translationController = TextEditingController(text: lesson?['Translation'] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Lesson' : 'Add New Lesson', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: descriptionTranslationController,
                    decoration: InputDecoration(labelText: 'Description Translation', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: imageURLController,
                    decoration: InputDecoration(labelText: 'Image URL', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: lessonIDController,
                    decoration: InputDecoration(labelText: 'Lesson ID', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: translationController,
                    decoration: InputDecoration(labelText: 'Translation', border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text(isEditing ? 'Update' : 'Add'),
              onPressed: () {
                final newLesson = {
                  'Name': nameController.text,
                  'Description': descriptionController.text,
                  'DescriptionTranslation': descriptionTranslationController.text,
                  'ImageURL': imageURLController.text,
                  'LessonID': lessonIDController.text,
                  'Translation': translationController.text,
                };
                if (isEditing) {
                  updateLesson(lesson['id'], newLesson);
                } else {
                  addLesson(newLesson);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> addLesson(Map<String, dynamic> lesson) async {
    try {
      await _firestore.collection(lessonCollection).add(lesson);
      fetchLessons();
    } catch (e) {
      print('Error adding lesson: $e');
    }
  }

  Future<void> updateLesson(String id, Map<String, dynamic> lesson) async {
    try {
      await _firestore.collection(lessonCollection).doc(id).update(lesson);
      fetchLessons();
    } catch (e) {
      print('Error updating lesson: $e');
    }
  }

  Future<void> deleteLesson(String id) async {
    try {
      await _firestore.collection(lessonCollection).doc(id).delete();
      fetchLessons();
    } catch (e) {
      print('Error deleting lesson: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lesson List', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => showAddEditDialog(),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: fetchLessons,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : lessons.isEmpty
                ? Center(child: Text('No lessons found', style: TextStyle(fontSize: 18)))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: Center(
                          child: Container(
                            constraints: BoxConstraints(maxWidth: 800),
                            child: Column(
                              children: lessons.map((lesson) {
                                return Card(
                                  elevation: 2,
                                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: ExpansionTile(
                                    leading: lesson['ImageURL'] != null
                                        ? Image.network(
                                            lesson['ImageURL'],
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                                          )
                                        : null,
                                    title: Text(lesson['Name'] ?? 'Unknown Lesson', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    subtitle: Text(lesson['Translation'] ?? 'No translation', style: TextStyle(fontSize: 14)),
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                                            Text(lesson['Description'] ?? 'N/A'),
                                            SizedBox(height: 8),
                                            Text('Description Translation:', style: TextStyle(fontWeight: FontWeight.bold)),
                                            Text(lesson['DescriptionTranslation'] ?? 'N/A'),
                                            SizedBox(height: 8),
                                            Text('Lesson ID: ${lesson['LessonID'] ?? 'N/A'}'),
                                            SizedBox(height: 16),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                ElevatedButton.icon(
                                                  icon: Icon(Icons.edit),
                                                  label: Text('Edit'),
                                                  onPressed: () => showAddEditDialog(lesson: lesson),
                                                ),
                                                SizedBox(width: 8),
                                                ElevatedButton.icon(
                                                  icon: Icon(Icons.delete),
                                                  label: Text('Delete'),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                  onPressed: () => showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text('Confirm Delete'),
                                                        content: Text('Are you sure you want to delete this lesson?'),
                                                        actions: [
                                                          TextButton(
                                                            child: Text('Cancel'),
                                                            onPressed: () => Navigator.of(context).pop(),
                                                          ),
                                                          ElevatedButton(
                                                            child: Text('Delete'),
                                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                            onPressed: () {
                                                              deleteLesson(lesson['id']);
                                                              Navigator.of(context).pop();
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddEditDialog(),
        child: Icon(Icons.add),
        tooltip: 'Add Lesson',
      ),
    );
  }
}