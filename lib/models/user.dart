class UserModel {
  final String userId;
  final String firstName;
  final String lastName;
  final String? fatherName;
  final String email;
  final DateTime birthday;
  final String phone;
  final String password;

  UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.fatherName,
    required this.email,
    required this.birthday,
    required this.phone,
    required this.password,
  });

  // Конструктор из JSON
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    userId: json['user_id'],
    firstName: json['first_name'],
    lastName: json['last_name'],
    fatherName: json['father_name'],
    email: json['email'],
    birthday: DateTime.parse(json['birthday']),
    phone: json['phone'],
    password: json['password'],
  );

  // Преобразование в JSON
  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'first_name': firstName,
    'last_name': lastName,
    'father_name': fatherName,
    'email': email,
    'birthday': birthday.toIso8601String(),
    'phone': phone,
    'password': password,
  };

  // Метод для вычисления возраста
  int get age {
    final now = DateTime.now();
    int years = now.year - birthday.year;
    if (now.month < birthday.month || (now.month == birthday.month && now.day < birthday.day)) {
      years--;
    }
    return years;
  }

  // Метод для создания пустого пользователя
  factory UserModel.empty() {
    return UserModel(
      userId: '',
      firstName: '',
      lastName: '',
      fatherName: '',
      email: '',
      birthday: DateTime(1900, 1, 1),
      phone: '',
      password: '',
    );
  }
}
