import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PhoneticListScreen extends StatefulWidget {
  @override
  _PhoneticListScreenState createState() => _PhoneticListScreenState();
}

class _PhoneticListScreenState extends State<PhoneticListScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool isLoading = false;
  List<Map<String, dynamic>> phonetics = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String phoneticCollection = 'Phonetic';

  @override
  void initState() {
    super.initState();
    fetchPhonetics();
  }

  Future<void> fetchPhonetics() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot snapshot =
          await _firestore.collection(phoneticCollection).get();
      setState(() {
        phonetics = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching phonetics: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void showAddEditDialog({Map<String, dynamic>? phonetic}) {
    final isEditing = phonetic != null;
    final TextEditingController descriptionController =
        TextEditingController(text: phonetic?['Description'] ?? '');
    final TextEditingController exampleController =
        TextEditingController(text: phonetic?['Example'] ?? '');
    final TextEditingController phoneticController =
        TextEditingController(text: phonetic?['Phonetic'] ?? '');
    final TextEditingController phoneticIDController =
        TextEditingController(text: phonetic?['PhoneticID'] ?? '');
    final TextEditingController phoneticTypeController =
        TextEditingController(text: phonetic?['PhoneticType'] ?? '');
    final TextEditingController youtubeVideoIDController =
        TextEditingController(text: phonetic?['YoutubeVideoID'] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Phonetic' : 'Add New Phonetic',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Container(
              width: 500, // Adjusted for web
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                        labelText: 'Description', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: exampleController,
                    decoration: InputDecoration(
                        labelText: 'Example', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: phoneticController,
                    decoration: InputDecoration(
                        labelText: 'Phonetic', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: phoneticIDController,
                    decoration: InputDecoration(
                        labelText: 'Phonetic ID', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: phoneticTypeController,
                    decoration: InputDecoration(
                        labelText: 'Phonetic Type',
                        border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: youtubeVideoIDController,
                    decoration: InputDecoration(
                        labelText: 'YouTube Video ID',
                        border: OutlineInputBorder()),
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
                final newPhonetic = {
                  'Description': descriptionController.text,
                  'Example': exampleController.text,
                  'Phonetic': phoneticController.text,
                  'PhoneticID': phoneticIDController.text,
                  'PhoneticType': phoneticTypeController.text,
                  'YoutubeVideoID': youtubeVideoIDController.text,
                };
                if (isEditing) {
                  updatePhonetic(phonetic['id'], newPhonetic);
                } else {
                  addPhonetic(newPhonetic);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> addPhonetic(Map<String, dynamic> phonetic) async {
    try {
      await _firestore.collection(phoneticCollection).add(phonetic);
      fetchPhonetics();
    } catch (e) {
      print('Error adding phonetic: $e');
    }
  }

  Future<void> updatePhonetic(String id, Map<String, dynamic> phonetic) async {
    try {
      await _firestore.collection(phoneticCollection).doc(id).update(phonetic);
      fetchPhonetics();
    } catch (e) {
      print('Error updating phonetic: $e');
    }
  }

  Future<void> deletePhonetic(String id) async {
    try {
      await _firestore.collection(phoneticCollection).doc(id).delete();
      fetchPhonetics();
    } catch (e) {
      print('Error deleting phonetic: $e');
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
        title: Text('Phonetic List',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => showAddEditDialog(),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: fetchPhonetics,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : phonetics.isEmpty
                ? Center(
                    child: Text('No phonetics found',
                        style: TextStyle(fontSize: 18)))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: Center(
                          child: Container(
                            constraints: BoxConstraints(
                                maxWidth: 1200), // Adjusted for web
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: phonetics.map((phonetic) {
                                return SizedBox(
                                  width: 350, // Adjusted for web
                                  child: Card(
                                    elevation: 2,
                                    child: ExpansionTile(
                                      title: Text(
                                          phonetic['Phonetic'] ??
                                              'Unknown Phonetic',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Text(
                                          phonetic['Example'] ?? 'No example',
                                          style: TextStyle(fontSize: 14)),
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Description:',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(phonetic['Description'] ??
                                                  'N/A'),
                                              SizedBox(height: 8),
                                              Text(
                                                  'Phonetic ID: ${phonetic['PhoneticID'] ?? 'N/A'}'),
                                              Text(
                                                  'Phonetic Type: ${phonetic['PhoneticType'] ?? 'N/A'}'),
                                              SizedBox(height: 16),
                                              // if (phonetic['YoutubeVideoID'] != null && phonetic['YoutubeVideoID'].isNotEmpty)
                                              //   buildYouTubePlayer(phonetic['YoutubeVideoID']),
                                              SizedBox(height: 16),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  ElevatedButton.icon(
                                                    icon: Icon(Icons.edit),
                                                    label: Text('Edit'),
                                                    onPressed: () =>
                                                        showAddEditDialog(
                                                            phonetic: phonetic),
                                                  ),
                                                  SizedBox(width: 8),
                                                  ElevatedButton.icon(
                                                    icon: Icon(Icons.delete),
                                                    label: Text('Delete'),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            backgroundColor:
                                                                Colors.red),
                                                    onPressed: () => showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              'Confirm Delete'),
                                                          content: Text(
                                                              'Are you sure you want to delete this phonetic?'),
                                                          actions: [
                                                            TextButton(
                                                              child: Text(
                                                                  'Cancel'),
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(),
                                                            ),
                                                            ElevatedButton(
                                                              child: Text(
                                                                  'Delete'),
                                                              style: ElevatedButton
                                                                  .styleFrom(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red),
                                                              onPressed: () {
                                                                deletePhonetic(
                                                                    phonetic[
                                                                        'id']);
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
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
        tooltip: 'Add Phonetic',
      ),
    );
  }
}
