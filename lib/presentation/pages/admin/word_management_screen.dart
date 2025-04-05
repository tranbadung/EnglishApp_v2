import 'package:flutter/material.dart';

import '../../../domain/entities/word/word.dart';
import 'database/database_helper.dart';

class WordManagementScreen extends StatefulWidget {
  @override
  _WordManagementScreenState createState() => _WordManagementScreenState();
}

class _WordManagementScreenState extends State<WordManagementScreen> {
  List<Word> words = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    refreshWords();
  }

  Future<void> refreshWords() async {
    try {
      setState(() => isLoading = true);
      final allWords = await DatabaseHelper.instance.getAllWords();
      setState(() {
        words = allWords;
        isLoading = false;
      });
    } catch (e) {
      print("Error refreshing words: $e");
      setState(() {
        isLoading = false;
        words = [];
      });
    }
  }

  Future<void> _showForm(Word? word) async {
    final wordController = TextEditingController(text: word?.word ?? '');
    final pronunciationController =
    TextEditingController(text: word?.pronunciation ?? '');
    final phoneticComponentsController =
    TextEditingController(text: word?.phoneticComponents.toString() ?? '');
    final phoneticIdController =
    TextEditingController(text: word?.phoneticID.toString() ?? '1');
    final translationController =
    TextEditingController(text: word?.translation ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 15,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: wordController,
                decoration: InputDecoration(labelText: 'Nhập từ'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: pronunciationController,
                decoration: InputDecoration(labelText: 'Phát âm'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: phoneticComponentsController,
                decoration: InputDecoration(labelText: 'Thành phần phát âm'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: phoneticIdController,
                decoration: InputDecoration(labelText: 'Phonetic ID'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: translationController,
                decoration: InputDecoration(labelText: 'Nghĩa'),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      if (word == null) {
                        // Create new word
                        final wordData = Word(
                          phoneticID:
                          int.tryParse(phoneticIdController.text) ?? 1,
                          word: wordController.text.trim(),
                          pronunciation: pronunciationController.text.trim(),
                          translation: translationController.text.trim(),
                          phoneticComponents: {'default': 1},
                        );

                        final id =
                        await DatabaseHelper.instance.createWord(wordData);
                        print("Created word with ID: $id"); // Debug log
                      } else {
                        // Update existing word
                        await DatabaseHelper.instance.updateWord(word);
                      }

                      Navigator.pop(context);
                      await refreshWords();
                    } catch (e) {
                      print("Error in word operation: $e");
                    }
                  },
                  child: Text(word == null ? 'Thêm mới' : 'Cập nhật'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteWord(Word word) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa từ'),
        content: Text('Bạn có chắc chắn muốn xóa từ "${word.word}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await DatabaseHelper.instance.deleteWord(word);
              Navigator.pop(context);
              refreshWords();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa từ "${word.word}"')),
              );
            },
            child: Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Quản lý từ vựng'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : words.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Không có dữ liệu'),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: refreshWords,
              child: Text('Tải lại'),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: words.length,
        itemBuilder: (context, index) {
          final word = words[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(word.word),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phát âm: ${word.pronunciation}'),
                  Text('Nghĩa: ${word.translation}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showForm(word),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteWord(word),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        child: Icon(Icons.add),
      ),
    );
  }
}
