import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class WordDetailPage extends StatefulWidget {
  final Map<String, dynamic> wordData;

  const WordDetailPage({Key? key, required this.wordData}) : super(key: key);

  @override
  _WordDetailPageState createState() => _WordDetailPageState();
}

class _WordDetailPageState extends State<WordDetailPage>
    with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  bool isFavorite = false;
  bool isPlaying = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initAnimation();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _speakWord() async {
    if (isPlaying) {
      await flutterTts.stop();
      setState(() => isPlaying = false);
      _animationController.reverse();
    } else {
      setState(() => isPlaying = true);
      _animationController.forward();
      await flutterTts.speak(widget.wordData['Word']);
      setState(() => isPlaying = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 50.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.wordData['Word'] ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.7),
                      Theme.of(context).primaryColor,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      if (widget.wordData['Pronunciation'] != null)
                        Text(
                          '/${widget.wordData['Pronunciation']}/',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white.withOpacity(0.9),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  setState(() => isFavorite = !isFavorite);
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: _speakWord,
                    icon: RotationTransition(
                      turns: _animation,
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.volume_up,
                        size: 28,
                      ),
                    ),
                    label: const Text(
                      'Phát âm',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                _buildSection(
                  title: 'Nghĩa của từ',
                  icon: Icons.translate,
                  content: widget.wordData['Translation'] ?? '',
                ),
                if (widget.wordData['PhoneticComponents'] != null)
                  _buildSection(
                    title: 'Thành phần phiên âm',
                    icon: Icons.record_voice_over,
                    content: widget.wordData['PhoneticComponents'],
                  ),
                _buildExamplesSection(),
                _buildNotesSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Tính năng chia sẻ sẽ có trong bản cập nhật!')),
          );
        },
        child: Icon(Icons.share),
        tooltip: 'Chia sẻ',
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExamplesSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.format_quote,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Ví dụ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Divider(height: 24),
              _buildExampleItem(
                'This is an example sentence.',
                'Đây là một câu ví dụ.',
              ),
              SizedBox(height: 12),
              _buildExampleItem(
                'Another example with this word.',
                'Một ví dụ khác với từ này.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExampleItem(String english, String vietnamese) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            english,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            vietnamese,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.note_add,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Note',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              Divider(height: 24),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Example",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    _animationController.dispose();
    super.dispose();
  }
}
