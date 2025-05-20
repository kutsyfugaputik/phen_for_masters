class DiscountModel {
  final int discountId;
  final String name;
  final double percentage;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;

  DiscountModel({
    required this.discountId,
    required this.name,
    required this.percentage,
    this.description,
    this.startDate,
    this.endDate,
  });

  factory DiscountModel.fromJson(Map<String, dynamic> json) => DiscountModel(
    discountId: json['discount_id'],
    name: json['name'],
    percentage: json['percentage'].toDouble(),
    description: json['description'],
    startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
    endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
  );

  Map<String, dynamic> toJson() => {
    'discount_id': discountId,
    'name': name,
    'percentage': percentage,
    'description': description,
    'start_date': startDate?.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
  };
}
