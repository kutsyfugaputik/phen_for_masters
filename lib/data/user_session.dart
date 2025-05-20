class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;

  UserSession._internal();

  String? masterId;
  String? userId;

  void clear() {
    masterId = null;
    userId = null;
  }
}
