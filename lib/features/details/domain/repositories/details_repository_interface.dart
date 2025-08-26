import 'package:sixam_mart/interfaces/repository_interface.dart';

abstract class DetailsRepositoryInterface extends RepositoryInterface {
   @override
  Future getList({int? offset, int userID});
}


// 100+