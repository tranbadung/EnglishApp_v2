import 'package:flutter/material.dart';
import '../../../domain/entities/category/category.dart';

class CategoryListWidget extends StatefulWidget {
  final List<Category> initialCategories;

  CategoryListWidget({required this.initialCategories});

  @override
  _CategoryListWidgetState createState() => _CategoryListWidgetState();
}

class _CategoryListWidgetState extends State<CategoryListWidget> {
  late List<Category> categories;

  @override
  void initState() {
    super.initState();
    categories = widget.initialCategories;
  }

  void _addCategory(Category category) {
    setState(() {
      categories.add(category);
    });
    _showNotification('Danh mục mới đã được thêm!');
  }

  void _editCategory(int index, Category newCategory) {
    setState(() {
      categories[index] = newCategory;
    });
    _showNotification('Danh mục đã được cập nhật!');
  }

  void _deleteCategory(int index) {
    setState(() {
      categories.removeAt(index);
    });
    _showNotification('Danh mục đã được xóa!');
  }

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            _showAddCategoryDialog();
          },
          child: Text('Thêm Danh Mục'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                title: Text(category.name),
                subtitle: Text(category.translation),
                onTap: () {
                  _showEditCategoryDialog(index);
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteConfirmationDialog(index);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddCategoryDialog() {
    String name = '';
    String translation = '';
    String imageUrl = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Thêm Danh Mục Mới'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Tên Danh Mục'),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Bản Dịch'),
                onChanged: (value) {
                  translation = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'URL Hình Ảnh'),
                onChanged: (value) {
                  imageUrl = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (name.isNotEmpty &&
                    translation.isNotEmpty &&
                    imageUrl.isNotEmpty) {
                  _addCategory(Category(
                      categoryID: 1,
                      name: name,
                      translation: translation,
                      imageUrl: imageUrl));
                  Navigator.of(context).pop();
                } else {
                  _showErrorDialog('Vui lòng điền đầy đủ thông tin!');
                }
              },
              child: Text('Thêm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(int index) {
    String name = categories[index].name;
    String translation = categories[index].translation;
    String imageUrl = categories[index].imageUrl;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sửa Danh Mục'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Tên Danh Mục'),
                onChanged: (value) {
                  name = value;
                },
                controller: TextEditingController(text: name),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Bản Dịch'),
                onChanged: (value) {
                  translation = value;
                },
                controller: TextEditingController(text: translation),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'URL Hình Ảnh'),
                onChanged: (value) {
                  imageUrl = value;
                },
                controller: TextEditingController(text: imageUrl),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (name.isNotEmpty &&
                    translation.isNotEmpty &&
                    imageUrl.isNotEmpty) {
                  _editCategory(
                      index,
                      Category(
                          categoryID: 1,
                          name: name,
                          translation: translation,
                          imageUrl: imageUrl));
                  Navigator.of(context).pop();
                } else {
                  _showErrorDialog('Vui lòng điền đầy đủ thông tin!');
                }
              },
              child: Text('Lưu'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Xác Nhận'),
          content: Text('Bạn có chắc chắn muốn xóa danh mục này?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteCategory(index);
              },
              child: Text('Xóa'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Lỗi'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
}
