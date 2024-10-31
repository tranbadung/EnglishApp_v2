class WritingEvaluation {
  final double score;
  final String feedback;
  final Map<String, double> criteriaScores;
  final String taskType;

  WritingEvaluation({
    required this.score,
    required this.feedback,
    required this.criteriaScores,
    required this.taskType,
  });

  factory WritingEvaluation.fromJson(Map<String, dynamic> json) {
    return WritingEvaluation(
      score: json['score'].toDouble(),
      feedback: json['feedback'],
      criteriaScores: Map<String, double>.from(json['criteriaScores']),
      taskType: json['taskType'],
    );
  }

  Map<String, dynamic> toJson() => {
        'score': score,
        'feedback': feedback,
        'criteriaScores': criteriaScores,
        'taskType': taskType,
      };
}
