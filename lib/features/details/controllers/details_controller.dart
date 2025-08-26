import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:sixam_mart/features/details/domain/model/media_model.dart';
import 'package:sixam_mart/features/details/domain/services/details_service_interface.dart';

class DetailsController extends GetxController implements GetxService {
  final DetailsServiceInterface detailsServiceInterface;
  DetailsController({required this.detailsServiceInterface});
  MediaModel? _mediaModel;
  bool isPhoto = true;
  MediaModel? get mediaModel {
   
    return _mediaModel;
  }

  Map<String, List<Datum>> events = {};

  void clearMediaModel() async{
    _mediaModel = null;
    events.clear();
    await changeMedia(true);
    update();
  }

  Future<void> getDetails(bool reload, int userID) async {
   
    if (reload) {
      _mediaModel = null;
      events.clear();
      update();
    }
    MediaModel? mediaModel =
        await detailsServiceInterface.getDetails(userID: userID);
    
    _mediaModel = null;
    update();
    _mediaModel = mediaModel;
    if (mediaModel != null) {
      events.clear();
      await getEvents(mediaModel);
    } else {
     
    }
    update();
  }

  Future<void> getEvents(MediaModel mediaModel) async {
    for (int i = 0; i < mediaModel.data!.length; i++) {
      if (!events.containsKey("${mediaModel.data![i].eventTitle}")) {
        events["${mediaModel.data![i].eventTitle}"] = [];
      }
      events["${mediaModel.data![i].eventTitle}"]!.add(mediaModel.data![i]);
    }
    update();
  }

  Future<void> changeMedia(bool isPhoto) async {
    this.isPhoto = isPhoto;
    update();
  }
}
