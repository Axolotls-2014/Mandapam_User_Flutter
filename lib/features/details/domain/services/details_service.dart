import 'package:sixam_mart/features/details/domain/model/media_model.dart';
import 'package:sixam_mart/features/details/domain/repositories/details_repository_interface.dart';
import 'package:sixam_mart/features/details/domain/services/details_service_interface.dart';

class DetailsService implements DetailsServiceInterface {
   final DetailsRepositoryInterface detailsRepositoryInterface;
   DetailsService({required this.detailsRepositoryInterface});

  @override
  Future<MediaModel?> getDetails({required int userID}) async {
    return await detailsRepositoryInterface.getList(userID: userID);
  }
}
