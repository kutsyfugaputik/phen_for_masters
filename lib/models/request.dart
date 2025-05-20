class RequestModel {
  final String requestId;
  final String clientId;
  final String userId;
  final String masterId;
  final int serviceId;
  final DateTime startTime;
  final DateTime endTime;
  final String price;
  final bool confirmation;
  final int statusId;
  final String? feedbackId;
  final int? discountId;

  const RequestModel({
    required this.requestId,
    required this.clientId,
    required this.userId,
    required this.masterId,
    required this.serviceId,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.confirmation,
    required this.statusId,
    this.feedbackId,
    this.discountId,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      requestId: json['request_id'] as String,
      clientId: json['client_id'] as String,
      userId: json['user_id'] as String,
      masterId: json['master_id'] as String,
      serviceId: json['service_id'] as int,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      price: json['price'] as String,
      confirmation: json['confirmation'] as bool,
      statusId: json['status_id'] as int,
      feedbackId: json['feedback_id'] as String?,
      discountId: json['discount_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'client_id': clientId,
      'user_id': userId,
      'master_id': masterId,
      'service_id': serviceId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'price': price,
      'confirmation': confirmation,
      'status_id': statusId,
      if (feedbackId != null) 'feedback_id': feedbackId,
      if (discountId != null) 'discount_id': discountId,
    };
  }
}
