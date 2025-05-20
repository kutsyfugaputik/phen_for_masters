class FeedbackModel {
  final String feedbackId;
  final int rating;
  final String text;
  final DateTime created;

  FeedbackModel({
    required this.feedbackId,
    required this.rating,
    required this.text,
    required this.created,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) => FeedbackModel(
    feedbackId: json['feedback_id'],
    rating: json['rating'],
    text: json['text'],
    created: DateTime.parse(json['created']),
  );

  Map<String, dynamic> toJson() => {
    'feedback_id': feedbackId,
    'rating': rating,
    'text': text,
    'created': created.toIso8601String(),
  };
}
