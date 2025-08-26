import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/details/domain/model/media_model.dart';
import 'package:sixam_mart/features/details/domain/repositories/details_repository_interface.dart';
import 'package:sixam_mart/util/app_constants.dart';

class DetailsRepository implements DetailsRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  DetailsRepository({required this.apiClient, required this.sharedPreferences});

  @override
  Future getList({int? offset, int? userID}) async {
    return await _getDetailsList(userID: userID);
  }

  Future<MediaModel?> _getDetailsList({int? userID}) async {
    // log("In FetchMedia");

    String? deviceToken = sharedPreferences.getString(AppConstants.token);

    final url =
        Uri.parse("https://mandapam.co/api/v1/events/getMediaByUserAndEvent");

    final headers = {
      "Authorization": "Bearer $deviceToken",
      "Content-Type": "application/json",
    };

    final body = jsonEncode({
      "user_id": userID,
    });


    MediaModel? mediaModel;
    // log("'{AppConstants.storeUri}filterBy?store_type=storeType&offset=offset&limit=12'::${'${AppConstants.storeUri}/$filterBy?store_type=$storeType&offset=$offset&limit=12'}");
    try {
      final response = await http.post(url, headers: headers, body: body);

      // log("In response.statusCode:::${response.statusCode}");

      if (response.statusCode == 200) {
        // Decode JSON response properly
        // final Map<String, dynamic> data = jsonDecode(response.body);
        // log("Decoded Response: $data");
        // log("Message Response: ${data["message"]}");
        mediaModel = mediaModelFromJson(response.body);

        // log("mediaModel:::${mediaModel.message}");

        // Example: Access specific fields
      } else {
        // log("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
    }

    // mediaModel = await apiClient.getData(
    //     '${AppConstants.storeUri}/$filterBy?store_type=$storeType&offset=$offset&limit=12');
    // if (response.statusCode == 200) {
    //   mediaModel = mediaModelFromJson(response.body);
    // }
    return mediaModel;
  }

//  Future<MediaModel?> _getDetailsList({ int? userID}) async {

//     MediaModel? mediaModel;

//     mediaModel = await apiClient.getDetailsList(userID:userID );

//     return mediaModel;
//   }

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