
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:sixam_mart/features/nearby/domain/model/decorator_model.dart';
import 'package:sixam_mart/features/nearby/domain/model/event_decorator_model.dart';
import 'package:sixam_mart/features/nearby/domain/services/decorator_service_interface.dart';

class DecoratorController extends GetxController implements GetxService {
  final DecoratorServiceInterface decoratorServiceInterface;
  DecoratorController({required this.decoratorServiceInterface});
  DecoratorModel? _decoratorModel;
  EventDecoratorModel? _eventDecoratorModel;
  bool isPhoto = true;
  DecoratorModel? get decoratorModel => _decoratorModel;
  EventDecoratorModel? get eventDecoratorModel => _eventDecoratorModel;

  Future<void> getNearByDecorator(bool reload) async {
    
    if (reload) {
      _decoratorModel = null;
      update();
    }
    DecoratorModel? decoratorModel =
        await decoratorServiceInterface.getDecoratorList();
  
    _decoratorModel = decoratorModel;
    update();
  }
  Future<void> getEventDecorator(bool reload) async {
    
    if (reload) {
      _eventDecoratorModel = null;
      update();
    }
    EventDecoratorModel? eventDecoratorModel =
        await decoratorServiceInterface.getEventDecoratorList();
 
    _eventDecoratorModel = eventDecoratorModel;

    
    update();
  }

  

  Future<void> changeMedia(bool isPhoto) async {
    this.isPhoto = isPhoto;
    update();
  }
}
