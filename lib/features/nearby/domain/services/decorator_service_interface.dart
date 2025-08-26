
import 'package:sixam_mart/features/nearby/domain/model/decorator_model.dart';
import 'package:sixam_mart/features/nearby/domain/model/event_decorator_model.dart';

abstract class DecoratorServiceInterface {
  Future<DecoratorModel?> getDecoratorList();
  Future<EventDecoratorModel?> getEventDecoratorList();
}
