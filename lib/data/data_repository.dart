import 'package:masters/models/discount.dart';
import 'package:masters/models/feedback.dart';
import 'package:masters/models/master.dart';
import 'package:masters/models/request.dart';
import 'package:masters/models/service.dart';
import 'package:masters/models/status.dart';
import 'package:masters/models/service_type.dart';
import 'package:masters/models/user.dart';
import 'package:masters/data/api_service.dart';

class DataRepository {
  final ApiService apiService;

  DataRepository({required this.apiService});

  Future<void> init() async {
    await apiService.initDio();
  }

  Future<List<DiscountModel>> getDiscounts() async {
    final data = await apiService.getDiscounts();
    return data.map((e) => DiscountModel.fromJson(e)).toList();
  }

  Future<List<FeedbackModel>> getFeedbacks() async {
    final data = await apiService.getFeedbacks();
    return data.map((e) => FeedbackModel.fromJson(e)).toList();
  }

  Future<List<MasterModel>> getMasters() async {
    final data = await apiService.getMasters();
    return data.map((e) => MasterModel.fromJson(e)).toList();
  }

  Future<List<RequestModel>> getReqMaster(String masterId) async {
    return await apiService.getReqMaster(masterId);
  }

  Future<List<ServiceTypeModel>> getTypes() async {
    final data = await apiService.getTypes();
    return data.map((e) => ServiceTypeModel.fromJson(e)).toList();
  }

  Future<List<ServiceModel>> getServices() async {
    final data = await apiService.getServices();
    return data.map((e) => ServiceModel.fromJson(e)).toList();
  }

  Future<List<StatusModel>> getStatuses() async {
    final data = await apiService.getStatuses();
    return data.map((e) => StatusModel.fromJson(e)).toList();
  }

  Future<List<UserModel>> getUsers() async {
    final data = await apiService.getUsers();
    return data.map((e) => UserModel.fromJson(e)).toList();
  }

  Future<void> postFeedback(Map<String, dynamic> data) async {
    await apiService.postFeedback(data);
  }

  Future<void> createRequest(Map<String, dynamic> data) async {
    await apiService.createRequest(data);
  }

  Future<void> registerUser(Map<String, dynamic> data) async {
    await apiService.registerUser(data);
  }

  Future<void> logoutUser() async {
    await apiService.logoutUser();
  }

  Future<void> completeRequest(String id) async {
    await apiService.completeRequest(id);
  }

  Future<void> cancelRequest(String id) async {
    await apiService.cancelRequest(id);
  }

  Future<void> confirmRequest(String id) async {
    await apiService.confirmRequest(id);
  }
}
