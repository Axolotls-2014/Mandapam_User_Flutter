import 'package:sixam_mart/features/details/domain/model/media_model.dart';

abstract class DetailsServiceInterface {
  Future<MediaModel?> getDetails({required int userID});
}
