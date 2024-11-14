import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class WordListScreen extends StatefulWidget {
  @override
  _WordListScreenState createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool isLoading = false;
  List<Map<String, dynamic>> words = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String wordCollection = 'Word';

  @override
  void initState() {
    super.initState();
    fetchWords();
  }

  Future<void> fetchWords() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot snapshot =
          await _firestore.collection(wordCollection).get();
      setState(() {
        words = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching words: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void showAddEditDialog({Map<String, dynamic>? word}) {
    final isEditing = word != null;
    final TextEditingController wordController =
        TextEditingController(text: word?['Word'] ?? '');
    final TextEditingController translationController =
        TextEditingController(text: word?['Translation'] ?? '');
    final TextEditingController pronunciationController =
        TextEditingController(text: word?['pronunciation'] ?? '');
    final TextEditingController phoneticComponentsController =
        TextEditingController(text: word?['PhoneticComponents'] ?? '');
    final TextEditingController phoneticIDController =
        TextEditingController(text: word?['PhoneticID'] ?? '');
    final TextEditingController wordIDController =
        TextEditingController(text: word?['WordID'] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Word' : 'Add New Word',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: wordController,
                    decoration: InputDecoration(
                        labelText: 'Word', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: translationController,
                    decoration: InputDecoration(
                        labelText: 'Translation', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: pronunciationController,
                    decoration: InputDecoration(
                        labelText: 'Pronunciation',
                        border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: phoneticComponentsController,
                    decoration: InputDecoration(
                        labelText: 'Phonetic Components',
                        border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: phoneticIDController,
                    decoration: InputDecoration(
                        labelText: 'Phonetic ID', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: wordIDController,
                    decoration: InputDecoration(
                        labelText: 'Word ID', border: OutlineInputBorder()),
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
                final newWord = {
                  'Word': wordController.text,
                  'Translation': translationController.text,
                  'pronunciation': pronunciationController.text,
                  'PhoneticComponents': phoneticComponentsController.text,
                  'PhoneticID': phoneticIDController.text,
                  'WordID': wordIDController.text,
                };
                if (isEditing) {
                  updateWord(word['id'], newWord);
                } else {
                  addWord(newWord);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> addWord(Map<String, dynamic> word) async {
    try {
      await _firestore.collection(wordCollection).add(word);
      fetchWords();
    } catch (e) {
      print('Error adding word: $e');
    }
  }

  Future<void> updateWord(String id, Map<String, dynamic> word) async {
    try {
      await _firestore.collection(wordCollection).doc(id).update(word);
      fetchWords();
    } catch (e) {
      print('Error updating word: $e');
    }
  }

  Future<void> deleteWord(String id) async {
    try {
      await _firestore.collection(wordCollection).doc(id).delete();
      fetchWords();
    } catch (e) {
      print('Error deleting word: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word List', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => showAddEditDialog(),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: fetchWords,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : words.isEmpty
                ? Center(
                    child:
                        Text('No words found', style: TextStyle(fontSize: 18)))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: Center(
                          child: Container(
                            constraints: BoxConstraints(maxWidth: 800),
                            child: Column(
                              children: words.map((word) {
                                return Card(
                                  elevation: 2,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                                word['Word'] ?? 'Unknown Word',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            content: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                    'Translation: ${word['Translation'] ?? 'N/A'}',
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                                SizedBox(height: 8),
                                                Text(
                                                    'Pronunciation: ${word['pronunciation'] ?? 'N/A'}',
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                                SizedBox(height: 8),
                                                Text(
                                                    'Phonetic Components: ${word['PhoneticComponents'] ?? 'N/A'}',
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                                SizedBox(height: 8),
                                                Text(
                                                    'Phonetic ID: ${word['PhoneticID'] ?? 'N/A'}',
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                                SizedBox(height: 8),
                                                Text(
                                                    'Word ID: ${word['WordID'] ?? 'N/A'}',
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                child: Text('Close'),
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    word['Word'] ??
                                                        'Unknown Word',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                SizedBox(height: 4),
                                                Text(
                                                    word['Translation'] ??
                                                        'No translation',
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () =>
                                                showAddEditDialog(word: word),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () => showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text('Confirm Delete'),
                                                  content: Text(
                                                      'Are you sure you want to delete this word?'),
                                                  actions: [
                                                    TextButton(
                                                      child: Text('Cancel'),
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                    ),
                                                    ElevatedButton(
                                                      child: Text('Delete'),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              backgroundColor:
                                                                  Colors.red),
                                                      onPressed: () {
                                                        deleteWord(word['id']);
                                                        Navigator.of(context)
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
    );
  }
}
