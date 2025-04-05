import 'package:flutter/material.dart';
 import '../../../domain/entities/category/category.dart';
import 'database/database_helper.dart';

class CategoryManagementScreen extends StatefulWidget {
  @override
  _CategoryManagementScreenState createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  List<Category> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    refreshCategories();
  }

  Future<void> refreshCategories() async {
    try {
      setState(() => isLoading = true);
      final allCategories = await DatabaseHelper.instance.getAllCategories();
      setState(() {
        categories = allCategories;
        isLoading = false;
      });
    } catch (e) {
      print("Error refreshing categories: $e");
      setState(() {
        isLoading = false;
        categories = [];
      });
    }
  }

  Future<void> _showForm(Category? category) async {
    final nameController = TextEditingController(text: category?.name ?? '');
    final translationController =
    TextEditingController(text: category?.translation ?? '');
    final imageURLController =
    TextEditingController(text: category?.imageUrl ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: 'Nhập tên danh mục'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: translationController,
              decoration: InputDecoration(hintText: 'Nghĩa'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: imageURLController,
              decoration: InputDecoration(hintText: 'URL hình ảnh'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final newCategory = Category(
                  categoryID: category?.categoryID ?? 0,
                  name: nameController.text,
                  translation: translationController.text,
                  imageUrl: imageURLController.text,
                );

                try {
                  if (category == null) {
                    await DatabaseHelper.instance.createCategory(newCategory);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Thêm danh mục thành công!')),
                    );
                  } else {
                    await DatabaseHelper.instance.updateCategory(newCategory);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cập nhật danh mục thành công!')),
                    );
                  }
                  Navigator.pop(context);
                  refreshCategories();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Có lỗi xảy ra: $e')),
                  );
                }
              },
              child: Text(category == null ? 'Thêm mới' : 'Cập nhật'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Category category) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa danh mục'),
        content: Text('Bạn có chắc chắn muốn xóa danh mục này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Đóng dialog
              try {
                await DatabaseHelper.instance
                    .deleteCategory(category.categoryID);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Xóa danh mục thành công!')),
                );
                refreshCategories();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Có lỗi xảy ra khi xóa: $e')),
                );
              }
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
        title: Text('Quản lý danh mục'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : categories.isEmpty
          ? Center(child: Text('Không có dữ liệu'))
          : ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            title: Text(category.name),
            subtitle: Text('Nghĩa: ${category.translation}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showForm(category),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _confirmDelete(category),
                ),
              ],
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
