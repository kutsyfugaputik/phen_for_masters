class ServiceTypeModel {
  final int serviceTypeId;
  final String name;
  final String? description;

  ServiceTypeModel({
    required this.serviceTypeId,
    required this.name,
    this.description,
  });

  factory ServiceTypeModel.fromJson(Map<String, dynamic> json) => ServiceTypeModel(
    serviceTypeId: json['service_type_id'],
    name: json['name'],
    description: json['description'],
  );

  Map<String, dynamic> toJson() => {
    'service_type_id': serviceTypeId,
    'name': name,
    'description': description,
  };
}
