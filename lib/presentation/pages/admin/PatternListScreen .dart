import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
 import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class PatternListScreen extends StatefulWidget {
  @override
  _PatternListScreenState createState() => _PatternListScreenState();
}

class _PatternListScreenState extends State<PatternListScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  bool isLoading = false;
  List<Map<String, dynamic>> patterns = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String patternCollection = 'Pattern';

  @override
  void initState() {
    super.initState();
    fetchPatterns();
  }

  Future<void> fetchPatterns() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot snapshot = await _firestore.collection(patternCollection).get();
      setState(() {
        patterns = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching patterns: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void showAddEditDialog({Map<String, dynamic>? pattern}) {
    final isEditing = pattern != null;
    final TextEditingController nameController = TextEditingController(text: pattern?['Name'] ?? '');
    final TextEditingController descriptionController = TextEditingController(text: pattern?['Description'] ?? '');
    final TextEditingController descriptionTranslationController = TextEditingController(text: pattern?['DescriptionTranslation'] ?? '');
    final TextEditingController dialogueController = TextEditingController(text: pattern?['Dialogue'] ?? '');
    final TextEditingController patternIDController = TextEditingController(text: pattern?['PatternID'] ?? '');
    final TextEditingController youtubeVideoIDController = TextEditingController(text: pattern?['YoutubeVideoID'] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Pattern' : 'Add New Pattern', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    controller: dialogueController,
                    decoration: InputDecoration(labelText: 'Dialogue', border: OutlineInputBorder()),
                    maxLines: 5,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: patternIDController,
                    decoration: InputDecoration(labelText: 'Pattern ID', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: youtubeVideoIDController,
                    decoration: InputDecoration(labelText: 'YouTube Video ID', border: OutlineInputBorder()),
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
                final newPattern = {
                  'Name': nameController.text,
                  'Description': descriptionController.text,
                  'DescriptionTranslation': descriptionTranslationController.text,
                  'Dialogue': dialogueController.text,
                  'PatternID': patternIDController.text,
                  'YoutubeVideoID': youtubeVideoIDController.text,
                };
                if (isEditing) {
                  updatePattern(pattern['id'], newPattern);
                } else {
                  addPattern(newPattern);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> addPattern(Map<String, dynamic> pattern) async {
    try {
      await _firestore.collection(patternCollection).add(pattern);
      fetchPatterns();
    } catch (e) {
      print('Error adding pattern: $e');
    }
  }

  Future<void> updatePattern(String id, Map<String, dynamic> pattern) async {
    try {
      await _firestore.collection(patternCollection).doc(id).update(pattern);
      fetchPatterns();
    } catch (e) {
      print('Error updating pattern: $e');
    }
  }

  Future<void> deletePattern(String id) async {
    try {
      await _firestore.collection(patternCollection).doc(id).delete();
      fetchPatterns();
    } catch (e) {
      print('Error deleting pattern: $e');
    }
  }

  // Widget buildYouTubePlayer(String videoId) {
  //   return YoutubePlayer(
  //     controller: YoutubePlayerController(
  //       initialVideoId: videoId,
  //       flags: YoutubePlayerFlags(
  //         autoPlay: false,
  //         mute: false,
  //       ),
  //     ),
  //     showVideoProgressIndicator: true,
  //     progressIndicatorColor: Colors.blueAccent,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pattern List', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => showAddEditDialog(),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: fetchPatterns,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : patterns.isEmpty
                ? Center(child: Text('No patterns found', style: TextStyle(fontSize: 18)))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: Center(
                          child: Container(
                            constraints: BoxConstraints(maxWidth: 800),
                            child: Column(
                              children: patterns.map((pattern) {
                                return Card(
                                  elevation: 2,
                                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: ExpansionTile(
                                    title: Text(pattern['Name'] ?? 'Unknown Pattern', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    subtitle: Text(pattern['Description'] ?? 'No description', style: TextStyle(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                                            Text(pattern['Description'] ?? 'N/A'),
                                            SizedBox(height: 8),
                                            Text('Description Translation:', style: TextStyle(fontWeight: FontWeight.bold)),
                                            Text(pattern['DescriptionTranslation'] ?? 'N/A'),
                                            SizedBox(height: 8),
                                            Text('Dialogue:', style: TextStyle(fontWeight: FontWeight.bold)),
                                            Text(pattern['Dialogue'] ?? 'N/A'),
                                            SizedBox(height: 8),
                                            Text('Pattern ID: ${pattern['PatternID'] ?? 'N/A'}'),
                                            SizedBox(height: 16),
                                            // if (pattern['YoutubeVideoID'] != null && pattern['YoutubeVideoID'].isNotEmpty)
                                            //   buildYouTubePlayer(pattern['YoutubeVideoID']),
                                            SizedBox(height: 16),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                ElevatedButton.icon(
                                                  icon: Icon(Icons.edit),
                                                  label: Text('Edit'),
                                                  onPressed: () => showAddEditDialog(pattern: pattern),
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
                                                        content: Text('Are you sure you want to delete this pattern?'),
                                                        actions: [
                                                          TextButton(
                                                            child: Text('Cancel'),
                                                            onPressed: () => Navigator.of(context).pop(),
                                                          ),
                                                          ElevatedButton(
                                                            child: Text('Delete'),
                                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                            onPressed: () {
                                                              deletePattern(pattern['id']);
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
        tooltip: 'Add Pattern',
      ),
    );
  }
}