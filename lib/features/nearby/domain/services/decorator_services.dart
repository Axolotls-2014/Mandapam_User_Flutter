import 'package:sixam_mart/features/nearby/domain/model/decorator_model.dart';
import 'package:sixam_mart/features/nearby/domain/model/event_decorator_model.dart';
import 'package:sixam_mart/features/nearby/domain/repositories/decorator_repository_interface.dart';
import 'package:sixam_mart/features/nearby/domain/services/decorator_service_interface.dart';

class DecoratorServices implements DecoratorServiceInterface {
   final DecoratorRepositoryInterface decoratorRepositoryInterface;
   DecoratorServices({required this.decoratorRepositoryInterface});

  @override
  Future<DecoratorModel?> getDecoratorList() async {
    return await decoratorRepositoryInterface.getList(isNearBy: true);
  }
   @override
  Future<EventDecoratorModel?> getEventDecoratorList() async {
    return await decoratorRepositoryInterface.getList(isEventDecorator: true);
  }
}
