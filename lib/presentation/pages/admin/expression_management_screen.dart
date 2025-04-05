import 'package:flutter/material.dart';

import '../../../domain/entities/expression/expression.dart';
import 'database/database_helper.dart';

class ExpressionManagementScreen extends StatefulWidget {
  @override
  _ExpressionManagementScreenState createState() =>
      _ExpressionManagementScreenState();
}

class _ExpressionManagementScreenState
    extends State<ExpressionManagementScreen> {
  List<Expression> expressions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    refreshExpressions();
  }

  Future<void> refreshExpressions() async {
    try {
      setState(() => isLoading = true);
      final allExpressions = await DatabaseHelper.instance.getAllExpressions();
      setState(() {
        expressions = allExpressions;
        isLoading = false;
      });
    } catch (e) {
      print("Error refreshing expressions: $e");
      setState(() {
        isLoading = false;
        expressions = [];
      });
    }
  }

  Future<void> _showForm(Expression? expression) async {
    final nameController = TextEditingController(text: expression?.name ?? '');
    final translationController =
    TextEditingController(text: expression?.translation ?? '');

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
              decoration: InputDecoration(hintText: 'Nhập biểu thức'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: translationController,
              decoration: InputDecoration(hintText: 'Nghĩa'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final newExpression = Expression(
                  expressionID: expression?.expressionID ?? 0,
                  name: nameController.text,
                  translation: translationController.text,
                  expressionTypeID: 0,
                );

                try {
                  if (expression == null) {
                    await DatabaseHelper.instance
                        .createExpression(newExpression);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Thêm biểu thức thành công!')),
                    );
                  } else {
                    await DatabaseHelper.instance
                        .updateExpression(newExpression);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cập nhật biểu thức thành công!')),
                    );
                  }
                  Navigator.pop(context);
                  refreshExpressions();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Có lỗi xảy ra: $e')),
                  );
                }
              },
              child: Text(expression == null ? 'Thêm mới' : 'Cập nhật'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Expression expression) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa biểu thức'),
        content: Text('Bạn có chắc chắn muốn xóa biểu thức này không?'),
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
                    .deleteExpression(expression.expressionID);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Xóa biểu thức thành công!')),
                );
                refreshExpressions();
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
        leading: null,
        title: Text('Quản lý biểu thức'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : expressions.isEmpty
          ? Center(child: Text('Không có dữ liệu'))
          : ListView.builder(
        itemCount: expressions.length,
        itemBuilder: (context, index) {
          final expression = expressions[index];
          return ListTile(
            title: Text(expression.name),
            subtitle: Text('Nghĩa: ${expression.translation}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showForm(expression),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _confirmDelete(expression),
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
