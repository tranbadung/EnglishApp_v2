import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TenseUsageListScreen extends StatefulWidget {
  @override
  _TenseUsageListScreenState createState() => _TenseUsageListScreenState();
}

class _TenseUsageListScreenState extends State<TenseUsageListScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool isLoading = false;
  List<Map<String, dynamic>> tenseUsages = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String tenseUsageCollection = 'TenseUsage';

  @override
  void initState() {
    super.initState();
    fetchTenseUsages();
  }

  Future<void> fetchTenseUsages() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot snapshot =
          await _firestore.collection(tenseUsageCollection).get();
      setState(() {
        tenseUsages = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching tense usages: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void showAddEditDialog({Map<String, dynamic>? tenseUsage}) {
    final isEditing = tenseUsage != null;
    final TextEditingController descriptionController =
        TextEditingController(text: tenseUsage?['Description'] ?? '');
    final TextEditingController descriptionTranslationController =
        TextEditingController(
            text: tenseUsage?['DescriptionTranslation'] ?? '');
    final TextEditingController exampleController =
        TextEditingController(text: tenseUsage?['Example'] ?? '');
    final TextEditingController tenseIDController =
        TextEditingController(text: tenseUsage?['TenseID'] ?? '');
    final TextEditingController tenseUsageIDController =
        TextEditingController(text: tenseUsage?['TenseUsageID'] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Tense Usage' : 'Add New Tense Usage',
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
                    controller: descriptionTranslationController,
                    decoration: InputDecoration(
                        labelText: 'Description Translation',
                        border: OutlineInputBorder()),
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
                    controller: tenseIDController,
                    decoration: InputDecoration(
                        labelText: 'Tense ID', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: tenseUsageIDController,
                    decoration: InputDecoration(
                        labelText: 'Tense Usage ID',
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
                final newTenseUsage = {
                  'Description': descriptionController.text,
                  'DescriptionTranslation':
                      descriptionTranslationController.text,
                  'Example': exampleController.text,
                  'TenseID': tenseIDController.text,
                  'TenseUsageID': tenseUsageIDController.text,
                };
                if (isEditing) {
                  updateTenseUsage(tenseUsage['id'], newTenseUsage);
                } else {
                  addTenseUsage(newTenseUsage);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> addTenseUsage(Map<String, dynamic> tenseUsage) async {
    try {
      await _firestore.collection(tenseUsageCollection).add(tenseUsage);
      fetchTenseUsages();
    } catch (e) {
      print('Error adding tense usage: $e');
    }
  }

  Future<void> updateTenseUsage(
      String id, Map<String, dynamic> tenseUsage) async {
    try {
      await _firestore
          .collection(tenseUsageCollection)
          .doc(id)
          .update(tenseUsage);
      fetchTenseUsages();
    } catch (e) {
      print('Error updating tense usage: $e');
    }
  }

  Future<void> deleteTenseUsage(String id) async {
    try {
      await _firestore.collection(tenseUsageCollection).doc(id).delete();
      fetchTenseUsages();
    } catch (e) {
      print('Error deleting tense usage: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tense Usage List',
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
        onRefresh: fetchTenseUsages,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : tenseUsages.isEmpty
                ? Center(
                    child: Text('No tense usages found',
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
                              children: tenseUsages.map((tenseUsage) {
                                return SizedBox(
                                  width: 350, // Adjusted for web
                                  child: Card(
                                    elevation: 2,
                                    child: ExpansionTile(
                                      title: Text(
                                          'Tense Usage ${tenseUsage['TenseUsageID'] ?? 'Unknown'}',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Text(
                                          tenseUsage['Description'] ??
                                              'No description',
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
                                              Text(tenseUsage['Description'] ??
                                                  'N/A'),
                                              SizedBox(height: 8),
                                              Text('Description Translation:',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(tenseUsage[
                                                      'DescriptionTranslation'] ??
                                                  'N/A'),
                                              SizedBox(height: 8),
                                              Text('Example:',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(tenseUsage['Example'] ??
                                                  'N/A'),
                                              SizedBox(height: 8),
                                              Text(
                                                  'Tense ID: ${tenseUsage['TenseID'] ?? 'N/A'}'),
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
                                                            tenseUsage:
                                                                tenseUsage),
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
                                                              'Are you sure you want to delete this tense usage?'),
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
                                                                deleteTenseUsage(
                                                                    tenseUsage[
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
        tooltip: 'Add Tense Usage',
      ),
    );
  }
}
