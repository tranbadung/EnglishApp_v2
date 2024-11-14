import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpressionTypeListScreen extends StatefulWidget {
  @override
  _ExpressionTypeListScreenState createState() => _ExpressionTypeListScreenState();
}

class _ExpressionTypeListScreenState extends State<ExpressionTypeListScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  bool isLoading = false;
  List<Map<String, dynamic>> expressionTypes = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String expressionTypeCollection = 'ExpressionType';

  @override
  void initState() {
    super.initState();
    fetchExpressionTypes();
  }

  Future<void> fetchExpressionTypes() async {
    setState(() {
      isLoading = true;
    });
    try {
      QuerySnapshot snapshot = await _firestore.collection(expressionTypeCollection).get();
      setState(() {
        expressionTypes = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching expression types: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void showAddEditDialog({Map<String, dynamic>? expressionType}) {
    final isEditing = expressionType != null;
    final TextEditingController descriptionController = TextEditingController(text: expressionType?['Description'] ?? '');
    final TextEditingController descriptionTranslationController = TextEditingController(text: expressionType?['DescriptionTranslation'] ?? '');
    final TextEditingController expressionTypeIDController = TextEditingController(text: expressionType?['ExpressionTypeID'] ?? '');
    final TextEditingController nameController = TextEditingController(text: expressionType?['Name'] ?? '');
    final TextEditingController translationController = TextEditingController(text: expressionType?['Translation'] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Expression Type' : 'Add New Expression Type', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    controller: expressionTypeIDController,
                    decoration: InputDecoration(labelText: 'Expression Type ID', border: OutlineInputBorder()),
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
                final newExpressionType = {
                  'Name': nameController.text,
                  'Description': descriptionController.text,
                  'DescriptionTranslation': descriptionTranslationController.text,
                  'ExpressionTypeID': expressionTypeIDController.text,
                  'Translation': translationController.text,
                };
                if (isEditing) {
                  updateExpressionType(expressionType['id'], newExpressionType);
                } else {
                  addExpressionType(newExpressionType);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> addExpressionType(Map<String, dynamic> expressionType) async {
    try {
      await _firestore.collection(expressionTypeCollection).add(expressionType);
      fetchExpressionTypes();
    } catch (e) {
      print('Error adding expression type: $e');
    }
  }

  Future<void> updateExpressionType(String id, Map<String, dynamic> expressionType) async {
    try {
      await _firestore.collection(expressionTypeCollection).doc(id).update(expressionType);
      fetchExpressionTypes();
    } catch (e) {
      print('Error updating expression type: $e');
    }
  }

  Future<void> deleteExpressionType(String id) async {
    try {
      await _firestore.collection(expressionTypeCollection).doc(id).delete();
      fetchExpressionTypes();
    } catch (e) {
      print('Error deleting expression type: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expression Type List', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => showAddEditDialog(),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: fetchExpressionTypes,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : expressionTypes.isEmpty
                ? Center(child: Text('No expression types found', style: TextStyle(fontSize: 18)))
                : ListView.builder(
                    itemCount: expressionTypes.length,
                    itemBuilder: (context, index) {
                      final expressionType = expressionTypes[index];
                      return Card(
                        elevation: 2,
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ExpansionTile(
                          title: Text(expressionType['Name'] ?? 'Unknown Expression Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Text(expressionType['Translation'] ?? 'No translation', style: TextStyle(fontSize: 14)),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(expressionType['Description'] ?? 'N/A'),
                                  SizedBox(height: 8),
                                  Text('Description Translation:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(expressionType['DescriptionTranslation'] ?? 'N/A'),
                                  SizedBox(height: 8),
                                  Text('Expression Type ID: ${expressionType['ExpressionTypeID'] ?? 'N/A'}'),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        icon: Icon(Icons.edit),
                                        label: Text('Edit'),
                                        onPressed: () => showAddEditDialog(expressionType: expressionType),
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
                                              content: Text('Are you sure you want to delete this expression type?'),
                                              actions: [
                                                TextButton(
                                                  child: Text('Cancel'),
                                                  onPressed: () => Navigator.of(context).pop(),
                                                ),
                                                ElevatedButton(
                                                  child: Text('Delete'),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                  onPressed: () {
                                                    deleteExpressionType(expressionType['id']);
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
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddEditDialog(),
        child: Icon(Icons.add),
        tooltip: 'Add Expression Type',
      ),
    );
  }
}