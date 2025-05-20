class ServiceModel {
  final int serviceId;
  final int serviceTypeId;
  final String name;
  final int duration;
  final double price;
  final String masterId;

  ServiceModel({
    required this.serviceId,
    required this.serviceTypeId,
    required this.name,
    required this.duration,
    required this.price,
    required this.masterId,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
    serviceId: json['service_id'],
    serviceTypeId: json['service_type_id'],
    name: json['name'],
    duration: json['duration'],
    price: _parsePrice(json['price']),
    masterId: json['master_id'],
  );

  Map<String, dynamic> toJson() => {
    'service_id': serviceId,
    'service_type_id': serviceTypeId,
    'name': name,
    'duration': duration,
    'price': price,
    'master_id': masterId,
  };

  static double _parsePrice(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final normalized = value.replaceAll(',', '.');
      return double.tryParse(normalized) ?? 0.00;
    }
    return 0.00;
  }

  /// Фабрика для пустого сервиса
  factory ServiceModel.empty() {
    return ServiceModel(
      serviceId: -1,
      serviceTypeId: -1,
      name: 'Неизвестно',
      duration: 0,
      price: 0.0,
      masterId: '',
    );
  }
}
