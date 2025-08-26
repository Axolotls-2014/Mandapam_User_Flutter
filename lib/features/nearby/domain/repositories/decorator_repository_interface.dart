import 'package:sixam_mart/interfaces/repository_interface.dart';

abstract class DecoratorRepositoryInterface extends RepositoryInterface {
   @override
  Future getList({int? offset, bool isNearBy = false, bool isEventDecorator = false,});
}
