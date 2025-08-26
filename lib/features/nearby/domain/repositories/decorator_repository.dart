import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/nearby/domain/model/decorator_model.dart';
import 'package:sixam_mart/features/nearby/domain/model/event_decorator_model.dart';
import 'package:sixam_mart/features/nearby/domain/repositories/decorator_repository_interface.dart';

class DecoratorRepository implements DecoratorRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  DecoratorRepository(
      {required this.apiClient, required this.sharedPreferences});

  @override
  Future getList({
    int? offset,
    bool isNearBy = false,
    bool isEventDecorator = false,
  }) async {
    if (isNearBy) {
      return await _getDecoratorList();
    }
    if (isEventDecorator) {
      return await _getEventDecoratorList();
    }
  }

  Future<DecoratorModel?> _getDecoratorList() async {
    DecoratorModel? decoratorModel;
    Response response = await apiClient.getData('/api/v1/events/get-decorator');
    if (response.statusCode == 200) {
      log("Decorator List Response: ${response.body}");
      decoratorModel = decoratorModelFromJson(response.body);
    }
    return decoratorModel;
  }

  Future<EventDecoratorModel?> _getEventDecoratorList() async {
    EventDecoratorModel? eventDecoratorModel;

    Response response =
        await apiClient.getData('/api/v1/events/get_decorator_as_per_event');

    if (response.statusCode == 200) {
      eventDecoratorModel = eventDecoratorModelFromJson(response.body);
    }

    return eventDecoratorModel;
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }
}
