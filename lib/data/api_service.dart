import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:masters/data/user_session.dart';
import 'package:masters/models/request.dart';
import 'package:logger/logger.dart';
class ApiService {
  late Dio _dio;
  bool _initialized = false;
  final logger = Logger();

  ApiService() {
    print('Создание экземпляра ApiService...');
    initDio();
  }

  Future<void> initDio() async {
    if (_initialized) return;

    print('Инициализация Dio...');
    final appDocDir = await getApplicationDocumentsDirectory();
    final cookieJar = PersistCookieJar(storage: FileStorage('${appDocDir.path}/.cookies'));

    _dio = Dio(BaseOptions(
      baseUrl: 'http://192.168.0.106:5000/api',
      headers: {'Content-Type': 'application/json'},
      validateStatus: (_) => true,
    ));

    _dio.interceptors.add(CookieManager(cookieJar));
    _initialized = true;
    print('Dio инициализирован с базовым URL: ${_dio.options.baseUrl}');

    await restoreApiUrl();
  }

  Future<void> setBaseUrl(String url) async {
    updateApiHost(url);
  }

  void updateApiHost(String newHost) {
    _dio.options.baseUrl = newHost;
    print('Базовый URL обновлён: $newHost');
    saveApiUrl(newHost);
  }

  Future<void> saveApiUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_url', url);
    print('URL сохранён в память: $url');
  }

  Future<void> restoreApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('api_url');
    if (savedUrl != null) {
      _dio.options.baseUrl = savedUrl;
      print('URL восстановлен из памяти: $savedUrl');
    }
  }

  Future<Response> _request(Future<Response> Function() request) async {
    if (!_initialized) await initDio();
    try {
      final response = await request();
      print('Запрос выполнен: ${response.requestOptions.method} ${response.requestOptions.path}');
      print('Ответ: ${response.statusCode}');
      return response;
    } catch (e) {
      print('Ошибка при выполнении запроса: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getAll(String endpoint) async {
    print('Получение всех данных с /$endpoint');
    final response = await _request(() => _dio.get('/$endpoint'));
    return response.data;
  }

  Future<dynamic> getById(String endpoint, String id) async {
    print('Получение элемента $id с /$endpoint');
    final response = await _request(() => _dio.get('/$endpoint/$id'));
    return response.data;
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    print('Отправка POST на /$endpoint с данными: $data');
    final response = await _request(() => _dio.post('/$endpoint', data: data));
    return response.data;
  }

  Future<void> logoutUser() async {
    print('Выход пользователя...');
    await _request(() => _dio.post('/users/logout'));
    UserSession().clear();
    print('Сессия очищена');
  }

  Future<String> checkConnection() async {
    print('Проверка подключения к серверу...');
    try {
      final response = await _request(() => _dio.get('/statuses'));
      return response.statusCode == 200
          ? 'Подключение к серверу успешно'
          : 'Ошибка сервера: ${response.statusCode}';
    } catch (_) {
      return 'Отсутствует подключение к серверу';
    }
  }

  // Методы API
  Future<List<dynamic>> getDiscounts() => getAll('discounts');
  Future<List<dynamic>> getFeedbacks() => getAll('feedbacks');
  Future<dynamic> getFeedbackById(String id) => getById('feedbacks', id);
  Future<List<dynamic>> getMasters() => getAll('masters');

  Future<List<String>> getMasterPhotos(String id) async {
    print('Получение фото мастера $id');
    final response = await _request(() => _dio.get('/masters/$id/photos'));
    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      final urls = data['imageUrls'];
      if (urls is List) {
        return urls.map((e) => e.toString()).toList();
      }
    }
    return [];
  }

  Future<List<dynamic>> getReqClient(String id) async {
    print('Получение заявок клиента $id');
    final response = await _request(() => _dio.get('/reqs/client/$id'));
    return response.data;
  }

  Future<List<RequestModel>> getReqMaster(String masterId) async {
    print('Получение заявок мастера $masterId');
    try {
      final response = await _request(() => _dio.get('/reqs/master/$masterId'));
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        List<RequestModel> requests = data.map((json) => RequestModel.fromJson(json)).toList();
        return requests;
      } else {
        print('Не удалось получить заявки мастера: ${response.statusCode}');
        throw Exception('Failed to load requests');
      }
    } catch (e) {
      print('Ошибка получения данных заявок: $e');
      throw Exception('Error fetching data: $e');
    }
  }

  Future<List<dynamic>> getTypes() => getAll('types');
  Future<dynamic> getTypeById(String id) => getById('types', id);
  Future<List<dynamic>> getServices() => getAll('serv');
  Future<dynamic> getServiceById(String id) => getById('serv', id);
  Future<List<dynamic>> getStatuses() => getAll('statuses');
  Future<dynamic> getStatusById(String id) => getById('statuses', id);
  Future<List<dynamic>> getUsers() => getAll('users');

  Future<void> postFeedback(Map<String, dynamic> data) async {
    print('Отправка отзыва: $data');
    await post('feedbacks', data);
  }

  Future<bool> loginMaster(String email, String password) async {
    print('Вход мастера с email: $email');
    try {
      final response = await _request(() => _dio.post('/masters/login', data: {
        'email': email,
        'password': password,
      }));
      final master = response.data['master_id'];
      UserSession().masterId = master['master_id'].toString();
      UserSession().userId = master['user_id'].toString();
      print('Мастер вошёл: ${UserSession().masterId}');
      return true;
    } catch (_) {
      print('Ошибка входа мастера');
      return false;
    }
  }

  Future<void> createRequest(Map<String, dynamic> data) async {
    print('Создание новой заявки: $data');
    await post('reqs/create', data);
  }

  Future<void> registerUser(Map<String, dynamic> data) async {
    print('Регистрация нового пользователя: $data');
    await post('users/register', data);
  }

  Future<void> completeRequest(String id) async {
    print('Завершение заявки: $id');
    await _request(() => _dio.put('/reqs/$id/complete'));
  }

  Future<void> cancelRequest(String id) async {
    print('Отмена заявки: $id');
    await _request(() => _dio.put('/reqs/$id/cancel'));
  }

  Future<void> confirmRequest(String id) async {
    print('Подтверждение заявки: $id');
    await _request(() => _dio.put('/reqs/$id/confirm'));
  }
}
