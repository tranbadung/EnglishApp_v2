import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_up/domain/entities/speech_word/speech_word_class.dart';
import 'package:speak_up/presentation/pages/search/search_details_view.dart';

class WordSearchPage extends StatefulWidget {
  @override
  _WordSearchPageState createState() => _WordSearchPageState();
}

class _WordSearchPageState extends State<WordSearchPage> {
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _searchHistory = [];
  final TextEditingController _searchController = TextEditingController();
  static const String SEARCH_HISTORY_KEY = 'search_history';

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load lịch sử tìm kiếm từ SharedPreferences
  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(SEARCH_HISTORY_KEY) ?? [];
    setState(() {
      _searchHistory = historyJson
          .map((item) => Map<String, dynamic>.from(json.decode(item)))
          .toList();
    });
  }

  Future<void> _saveToHistory(Map<String, dynamic> word) async {
    final existingIndex =
        _searchHistory.indexWhere((item) => item['WordID'] == word['WordID']);

    if (existingIndex != -1) {
      _searchHistory.removeAt(existingIndex);
    }

    setState(() {
      _searchHistory.insert(0, word);
      if (_searchHistory.length > 50) {
        _searchHistory.removeLast();
      }
    });

    // Lưu vào SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final historyJson =
        _searchHistory.map((item) => json.encode(item)).toList();
    await prefs.setStringList(SEARCH_HISTORY_KEY, historyJson);
  }

  Future<void> _removeFromHistory(int index) async {
    setState(() {
      _searchHistory.removeAt(index);
    });

    final prefs = await SharedPreferences.getInstance();
    final historyJson =
        _searchHistory.map((item) => json.encode(item)).toList();
    await prefs.setStringList(SEARCH_HISTORY_KEY, historyJson);
  }

  Future<void> _clearHistory() async {
    setState(() {
      _searchHistory.clear();
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SEARCH_HISTORY_KEY);
  }

  void _searchWords(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    try {
      final db = await WordDatabase.instance.database;
      final results = await db.rawQuery('''
        SELECT Word.WordID, Word.Word, Word.Pronunciation, 
               PhoneticComponents, PhoneticID, Translation
        FROM Word
        WHERE Word.Word LIKE ?
      ''', ['%$query%']);

      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      print('Error searching words: $e');
    }
  }

  void _navigateToWordDetail(Map<String, dynamic> word) async {
    // Lưu từ vào lịch sử trước khi chuyển trang
    await _saveToHistory(word);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WordDetailPage(wordData: word),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tìm kiếm từ vựng'),
        elevation: 0,
        actions: [
          if (_searchHistory.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear_all),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Xóa lịch sử'),
                    content:
                        Text('Bạn có chắc muốn xóa toàn bộ lịch sử tìm kiếm?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () {
                          _clearHistory();
                          Navigator.pop(context);
                        },
                        child: Text('Xóa'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _searchWords,
              decoration: InputDecoration(
                labelText: 'Nhập từ cần tìm',
                hintText: 'Ví dụ: book, read...',
                prefixIcon: Icon(Icons.search, color: Colors.purple.shade300),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.purple.shade200),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
          Expanded(
            child: _searchResults.isEmpty
                ? _buildSearchHistory()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory() {
    if (_searchHistory.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isEmpty
              ? 'Hãy nhập từ bạn muốn tìm kiếm'
              : 'Không tìm thấy kết quả',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Lịch sử tìm kiếm',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade600,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _searchHistory.length,
            itemBuilder: (context, index) {
              final word = _searchHistory[index];
              return Dismissible(
                key: Key(word['WordID'].toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20.0),
                  color: Colors.red,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) {
                  _removeFromHistory(index);
                },
                child: Card(
                  margin: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: InkWell(
                    onTap: () => _navigateToWordDetail(word),
                    child: ListTile(
                      title: Text(
                        word['Word'] ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (word['Pronunciation'] != null)
                            Text(
                              '/${word['Pronunciation']}/',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[600],
                              ),
                            ),
                          if (word['Translation'] != null)
                            Text(
                              word['Translation'],
                              style: TextStyle(
                                color: Colors.black87,
                              ),
                            ),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final word = _searchResults[index];
        return Card(
          margin: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 4.0,
          ),
          child: InkWell(
            onTap: () => _navigateToWordDetail(word),
            child: ListTile(
              leading: Icon(Icons.book, color: Colors.purple.shade300),
              title: Text(
                word['Word'] ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (word['Pronunciation'] != null)
                    Text(
                      '/${word['Pronunciation']}/',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                  if (word['Translation'] != null)
                    Text(
                      word['Translation'],
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                ],
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.purple.shade300),
            ),
          ),
        );
      },
    );
  }
}
