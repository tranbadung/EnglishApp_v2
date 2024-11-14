import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class IdiomListScreen extends StatefulWidget {
  @override
  _IdiomListScreenState createState() => _IdiomListScreenState();
}

class _IdiomListScreenState extends State<IdiomListScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool isLoading = false;
  List<Map<String, dynamic>> idioms = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String idiomCollection = 'Idiom';
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchIdioms();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> fetchIdioms() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot snapshot =
          await _firestore.collection(idiomCollection).get();
      setState(() {
        idioms = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching idioms: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void showAddEditDialog({Map<String, dynamic>? idiom}) {
    final isEditing = idiom != null;
    final TextEditingController nameController =
        TextEditingController(text: idiom?['Name'] ?? '');
    final TextEditingController descriptionController =
        TextEditingController(text: idiom?['Description'] ?? '');
    final TextEditingController descriptionTranslationController =
        TextEditingController(text: idiom?['DescriptionTranslation'] ?? '');
    final TextEditingController audioEndpointController =
        TextEditingController(text: idiom?['AudioEndpoint'] ?? '');
    final TextEditingController idiomIDController =
        TextEditingController(text: idiom?['IdiomID'] ?? '');
    final TextEditingController idiomTypeIDController =
        TextEditingController(text: idiom?['IdiomTypeID'] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Idiom' : 'Add New Idiom',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                        labelText: 'Idiom', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                        labelText: 'Description', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: descriptionTranslationController,
                    decoration: InputDecoration(
                        labelText: 'Description Translation',
                        border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: audioEndpointController,
                    decoration: InputDecoration(
                        labelText: 'Audio Endpoint',
                        border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: idiomIDController,
                    decoration: InputDecoration(
                        labelText: 'Idiom ID', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: idiomTypeIDController,
                    decoration: InputDecoration(
                        labelText: 'Idiom Type ID',
                        border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                final newIdiom = {
                  'Name': nameController.text,
                  'Description': descriptionController.text,
                  'DescriptionTranslation':
                      descriptionTranslationController.text,
                  'AudioEndpoint': audioEndpointController.text,
                  'IdiomID': idiomIDController.text,
                  'IdiomTypeID': idiomTypeIDController.text,
                };
                if (isEditing) {
                  updateIdiom(idiom['id'], newIdiom);
                } else {
                  addIdiom(newIdiom);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> addIdiom(Map<String, dynamic> idiom) async {
    try {
      await _firestore.collection(idiomCollection).add(idiom);
      fetchIdioms();
    } catch (e) {
      print('Error adding idiom: $e');
    }
  }

  Future<void> updateIdiom(String id, Map<String, dynamic> idiom) async {
    try {
      await _firestore.collection(idiomCollection).doc(id).update(idiom);
      fetchIdioms();
    } catch (e) {
      print('Error updating idiom: $e');
    }
  }

  Future<void> deleteIdiom(String id) async {
    try {
      await _firestore.collection(idiomCollection).doc(id).delete();
      fetchIdioms();
    } catch (e) {
      print('Error deleting idiom: $e');
    }
  }

  Future<void> playAudio(String audioEndpoint) async {
    try {
      await audioPlayer.play(UrlSource(audioEndpoint));
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Idiom List', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => showAddEditDialog(),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: fetchIdioms,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : idioms.isEmpty
                ? Center(
                    child:
                        Text('No idioms found', style: TextStyle(fontSize: 18)))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: Center(
                          child: Container(
                            constraints: BoxConstraints(maxWidth: 800),
                            child: Column(
                              children: idioms.map((idiom) {
                                return Card(
                                  elevation: 2,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: ExpansionTile(
                                    title: Text(
                                        idiom['Name'] ?? 'Unknown Idiom',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(
                                        idiom['Description'] ??
                                            'No description',
                                        style: TextStyle(fontSize: 14),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
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
                                            Text(idiom['Description'] ?? 'N/A'),
                                            SizedBox(height: 8),
                                            Text('Translation:',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(idiom[
                                                    'DescriptionTranslation'] ??
                                                'N/A'),
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Text('Audio:',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                SizedBox(width: 8),
                                                IconButton(
                                                  icon: Icon(Icons.play_arrow),
                                                  onPressed: () => playAudio(
                                                      idiom['AudioEndpoint']),
                                                ),
                                              ],
                                            ),
                                            Text(
                                                'Idiom ID: ${idiom['IdiomID'] ?? 'N/A'}'),
                                            Text(
                                                'Idiom Type ID: ${idiom['IdiomTypeID'] ?? 'N/A'}'),
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
                                                          idiom: idiom),
                                                ),
                                                SizedBox(width: 8),
                                                ElevatedButton.icon(
                                                  icon: Icon(Icons.delete),
                                                  label: Text('Delete'),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.red),
                                                  onPressed: () => showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertDialog(
                                                        title: Text(
                                                            'Confirm Delete'),
                                                        content: Text(
                                                            'Are you sure you want to delete this idiom?'),
                                                        actions: [
                                                          TextButton(
                                                            child:
                                                                Text('Cancel'),
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(),
                                                          ),
                                                          ElevatedButton(
                                                            child:
                                                                Text('Delete'),
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red),
                                                            onPressed: () {
                                                              deleteIdiom(
                                                                  idiom['id']);
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
        tooltip: 'Add Idiom',
      ),
    );
  }
}
