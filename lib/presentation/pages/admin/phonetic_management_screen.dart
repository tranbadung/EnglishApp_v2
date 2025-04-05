import 'package:flutter/material.dart';
import 'package:speak_up/presentation/pages/admin/database/model/phonetic_model.dart';

 import 'database/database_helper.dart';


class PhoneticManagementScreen extends StatefulWidget {
  @override
  _PhoneticManagementScreenState createState() =>
      _PhoneticManagementScreenState();
}

class _PhoneticManagementScreenState extends State<PhoneticManagementScreen> {
  List<Phonetic> phonetics = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    refreshPhonetics();
  }

  Future<void> refreshPhonetics() async {
    try {
      final allPhonetics = await DatabaseHelper.instance.getAllPhonetics();
      setState(() {
        phonetics = allPhonetics;
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật danh sách thành công!')),
      );
    } catch (e) {
      print("Error refreshing phonetics: $e");
      setState(() {
        isLoading = false;
        phonetics = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi làm mới danh sách!')),
      );
    }
  }

  Future<void> _addPhonetic() async {
    final phoneticController = TextEditingController();
    final youtubeIdController = TextEditingController();
    final exampleController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thêm phát âm mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: phoneticController,
                decoration: InputDecoration(labelText: 'Phát âm'),
              ),
              TextField(
                controller: youtubeIdController,
                decoration: InputDecoration(labelText: 'Youtube Video ID'),
              ),
              TextField(
                controller: exampleController,
                decoration: InputDecoration(labelText: 'Ví dụ'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              var newPhonetic = Phonetic(
                phonetic: phoneticController.text,
                youtubeVideoId: youtubeIdController.text,
                example: exampleController.text,
                phoneticType: 1,
                description: '',
              );

              final id =
              await DatabaseHelper.instance.createPhonetic(newPhonetic);

              if (id != -1) {
                newPhonetic.phoneticID = id;
                setState(() {
                  phonetics.add(newPhonetic);
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Thêm phát âm thành công')),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Thêm phát âm thất bại')),
                );
              }
            },
            child: Text('Thêm'),
          ),
        ],
      ),
    );
  }

  Future<void> _editPhonetic(Phonetic phonetic) async {
    final phoneticController = TextEditingController(text: phonetic.phonetic);
    final typeController =
    TextEditingController(text: phonetic.phoneticType.toString());
    final youtubeIdController =
    TextEditingController(text: phonetic.youtubeVideoId);
    final exampleController = TextEditingController(text: phonetic.example);
    final descriptionController =
    TextEditingController(text: phonetic.description);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sửa phát âm'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: phoneticController,
                decoration: InputDecoration(labelText: 'Phát âm'),
              ),
              TextField(
                controller: typeController,
                decoration: InputDecoration(labelText: 'Loại phát âm'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: youtubeIdController,
                decoration: InputDecoration(labelText: 'Youtube Video ID'),
              ),
              TextField(
                controller: exampleController,
                decoration: InputDecoration(labelText: 'Ví dụ'),
                maxLines: null,
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Mô tả'),
                maxLines: null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedPhonetic = Phonetic(
                phoneticID: phonetic.phoneticID,
                phonetic: phoneticController.text,
                phoneticType: int.tryParse(typeController.text) ?? 0,
                youtubeVideoId: youtubeIdController.text,
                example: exampleController.text,
                description: descriptionController.text,
              );

              final success =
              await DatabaseHelper.instance.updatePhonetic(updatedPhonetic);
              if (success) {
                Navigator.pop(context);
                await refreshPhonetics();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cập nhật phát âm thành công')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cập nhật phát âm thất bại')),
                );
              }
            },
            child: Text('Cập nhật'),
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
        leading: null,
        title: Text('Quản lý từ phát âm'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: phonetics.length,
        itemBuilder: (context, index) {
          final phonetic = phonetics[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(phonetic.phonetic),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Video ID: ${phonetic.youtubeVideoId}'),
                  Text('Ví dụ: ${phonetic.example}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editPhonetic(phonetic),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Xác nhận xóa'),
                          content:
                          Text('Bạn có chắc muốn xóa phát âm này?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: Text('Hủy'),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: Text('Xóa'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        bool exists = await DatabaseHelper.instance
                            .phoneticExists(phonetic.phoneticID!);
                        if (exists) {
                          final success = await DatabaseHelper.instance
                              .deletePhonetic(phonetic.phoneticID!);
                          if (success) {
                            await refreshPhonetics();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                  Text('Xóa phát âm thành công')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Xóa phát âm thất bại')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Phát âm không tồn tại trong cơ sở dữ liệu.')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPhonetic,
        child: Icon(Icons.add),
      ),
    );
  }
}
