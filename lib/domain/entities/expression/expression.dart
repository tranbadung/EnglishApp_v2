class Expression {
  final int expressionID;
  final String name;
  final int expressionTypeID;
  final String translation;

  Expression({
    required this.expressionID,
    required this.name,
    required this.expressionTypeID,
    required this.translation,
  });
  Map<String, dynamic> toMap() {
    return {
      'ExpressionID': expressionID,
      'Name': name,
      'Translation': translation,
    };
  }

  // Tạo đối tượng từ Map
  factory Expression.fromMap(Map<String, dynamic> map) {
    return Expression(
      expressionID: map['ExpressionID'],
      name: map['Name'],
      translation: map['Translation'],
      expressionTypeID: map['ExpressionID'],
    );
  }

  factory Expression.initial() {
    return Expression(
      expressionID: 0,
      name: '',
      expressionTypeID: 0,
      translation: '',
    );
  }
}
