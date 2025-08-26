import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/features/media/wishlist_model.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'dart:async';

class ApiService {
  final SharedPreferences sharedPreferences;
  final ApiClient apiClient;

  ApiService({
    required this.sharedPreferences,
    required this.apiClient,
  });

  Future<Map<String, dynamic>?> userLogin({
    required String phone,
    required String name,
  }) async {
    const String url = 'https://mandapam.co/api/v1/auth/user_login';
    String? token = sharedPreferences.getString(AppConstants.token);
    String? deviceToken = await FirebaseMessaging.instance.getToken();

    print('REQUEST URL: $url');
    print('HEADERS: ${{
      'Authorization': 'Bearer $token',
    }}');
    print('REQUEST PARAMETERS: ${{
      'phone': phone,
      'name': name,
      'usertype': 'User',
      'cm_firebase_token': deviceToken ?? '',
    }}');

    final headers = {
      'Authorization': 'Bearer $token',
    };

    final body = {
      'phone': phone,
      'name': name,
      'usertype': 'User',
      'cm_firebase_token': deviceToken ?? '',
    };

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      print('RESPONSE STATUS: ${response.statusCode}');
      print('RESPONSE HEADERS: ${response.headers}');
      print('RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'error': 'Server returned ${response.statusCode}'};
    } on TimeoutException {
      print('REQUEST TIMED OUT');
      return {'error': 'Request timed out'};
    } catch (e) {
      print('ERROR: $e');
      return {'error': 'Unexpected error occurred'};
    }
  }

  Future<List<Map<String, dynamic>>?> fetchEvents() async {
    String? deviceToken = sharedPreferences.getString(AppConstants.token);

    if (deviceToken == null) {
      print("Error: Device Token is null");
      return null;
    }

    final url = Uri.parse('${AppConstants.baseUrl}/api/v1/events');
    final headers = {'Authorization': 'Bearer $deviceToken'};

    print("Request URL: $url");
    print("Request Headers: $headers");

    final response = await http.get(url, headers: headers);

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Parsed Response Data: $data");

      if (data['Events'] != null) {
        final List<Map<String, dynamic>> eventsList =
            List<Map<String, dynamic>>.from(
          data['Events']
              .map((event) => {'id': event['id'], 'title': event['title']}),
        );
        print("Extracted Events List: $eventsList");
        return eventsList;
      }
    }
    return null;
  }

  // get-decorator

  Future<dynamic> getMediaByUserAndEvent({
    required String userId,
    int? eventId,
    int? batchId,
  }) async {
    final token = sharedPreferences.getString(AppConstants.token);
    const String url =
        'https://mandapam.co/api/v1/events/getMediaByUserAndEvent';

    String? latitude;
    String? longitude;
    String? zoneId;

    if (sharedPreferences.containsKey(AppConstants.userAddress)) {
      try {
        AddressModel addressModel = AddressModel.fromJson(
          jsonDecode(sharedPreferences.getString(AppConstants.userAddress)!),
        );
        latitude = addressModel.latitude ?? '';
        longitude = addressModel.longitude ?? '';
        if (addressModel.zoneIds != null && addressModel.zoneIds!.isNotEmpty) {
          zoneId = addressModel.zoneIds!.first.toString();
        }
      } catch (_) {}
    }

    final Map<String, String> headers = {
      'latitude': latitude ?? '',
      'longitude': longitude ?? '',
      'zoneId': zoneId ?? '',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> body = {
      'user_id': userId.toString(),
    };

    if (eventId != null) {
      body['event_id'] = eventId.toString();
    }

    print('URL: $url');
    print('Headers: $headers');
    print('Request Body: $body');

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  Future<Map<String, String>?> getAppVersion() async {
    const String url = 'https://mandapam.co/api/v1/auth/app_version';

    try {
      final response = await http.get(Uri.parse(url));

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['version'] != null) {
          final Map<String, String> versionMap = {};
          for (var version in data['version']) {
            versionMap[version['key']] = version['value'];
          }
          print('App Versions: $versionMap');
          return versionMap;
        }
      }
    } catch (e) {
      print("Error fetching app version1: $e");
    }
    return null;
  }

  Future<dynamic> getNearbyDecoratorsMedia({
    required int userId,
    required int eventId,
  }) async {
    var token = sharedPreferences.getString(AppConstants.token);
    if (token == null) {
      String? tokenValue = sharedPreferences.getString('token');
      token = tokenValue ?? '';
    }
    const String url =
        'https://mandapam.co/api/v1/events/getNearbyDecoratorsMedia';

    String? latitude;
    String? longitude;
    String? zoneId;

    if (sharedPreferences.containsKey(AppConstants.userAddress)) {
      try {
        AddressModel addressModel = AddressModel.fromJson(
          jsonDecode(sharedPreferences.getString(AppConstants.userAddress)!),
        );
        latitude = addressModel.latitude ?? '';
        longitude = addressModel.longitude ?? '';
        if (addressModel.zoneIds != null && addressModel.zoneIds!.isNotEmpty) {
          zoneId = addressModel.zoneIds!.first.toString();
        }
      } catch (e, stack) {
        print('❌ Error parsing address: $e');
        print(stack);
      }
    }

    final Map<String, String> headers = {
      'latitude': latitude ?? '',
      'longitude': longitude ?? '',
      'zoneId': zoneId ?? '',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> body = {
      'user_id': userId.toString(),
      'event_id': eventId.toString(),
    };

    // 🔍 Debug: Request details
    log('\n===== 🌐 API REQUEST =====');
    log('URL: $url');
    log('Headers: ${jsonEncode(headers)}');
    log('Body: ${jsonEncode(body)}');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      // 🔍 Debug: Response details
      print('\n===== 📩 API RESPONSE =====');
      print('Status Code: ${response.statusCode}');
      print('Raw Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Success Response Parsed');
        return jsonDecode(response.body);
      } else {
        print('⚠️ Error Response Parsed');
        return {
          'status': response.statusCode,
          'error': response.body,
        };
      }
    } catch (e, stack) {
      // 🔍 Debug: Exception
      print('\n===== ❌ API EXCEPTION =====');
      print('Error: $e');
      print(stack);
      return {
        'status': 'exception',
        'error': e.toString(),
      };
    }
  }

//   WHISHLIST FUNCTIONALITY

  Future<Map<String, dynamic>?> addToWishlist({
    required int itemId,
    required int userId,
  }) async {
    const String url = 'https://mandapam.co/api/v1/customer/wish-list/add';
    String? token = sharedPreferences.getString(AppConstants.token);

    debugPrint('REQUEST URL: $url');
    debugPrint('HEADERS: ${{
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    }}');
    debugPrint('REQUEST PARAMETERS: ${{
      'item_id': itemId,
      'user_id': userId,
    }}');

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final body = {
      'item_id': itemId,
      'user_id': userId,
    };

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('RESPONSE STATUS: ${response.statusCode}');
      debugPrint('RESPONSE HEADERS: ${response.headers}');
      debugPrint('RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'error': 'Server returned ${response.statusCode}'};
    } on TimeoutException catch (_) {
      debugPrint('REQUEST TIMED OUT');
      return {'error': 'Request timed out'};
    } catch (e) {
      debugPrint('ERROR: $e');
      return {'error': 'Unexpected error occurred'};
    }
  }

  Future<Map<String, dynamic>?> removeFromWishlist({
    required int itemId,
  }) async {
    final String url =
        'https://mandapam.co/api/v1/customer/wish-list/remove?item_id=$itemId';
    String? token = sharedPreferences.getString(AppConstants.token);

    debugPrint('REQUEST URL: $url');
    debugPrint('HEADERS: ${{
      'Authorization': 'Bearer $token',
    }}');

    final headers = {
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('RESPONSESSTATUS: ${response.statusCode}');
      debugPrint('RESPONSE HEADERS: ${response.headers}');
      debugPrint('RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'error': 'Server returned ${response.statusCode}'};
    } on TimeoutException catch (_) {
      debugPrint('REQUEST TIMED OUT');
      return {'error': 'Request timed out'};
    } catch (e) {
      debugPrint('ERROR: $e');
      return {'error': 'Unexpected error occurred'};
    }
  }

  Future<WishlistResponse> getWishlist({required int userId}) async {
    print('========== Entered getWishlist ==========');
    print('User ID: $userId');

    final String url =
        'https://mandapam.co/api/v1/customer/wish-list/getWishlist_user?user_id=$userId';
    String? token = sharedPreferences.getString(AppConstants.token);

    print('Token: $token');

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    print('REQUEST URL: $url');
    print('REQUEST HEADERS: $headers');

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      print('RESPONSE STATUS CODE: ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('Decoded JSON: $decoded');
        return WishlistResponse.fromJson(decoded);
      }
      throw Exception('Server returned ${response.statusCode}');
    } on TimeoutException {
      throw Exception('Request timed out');
    } catch (e) {
      throw Exception('Failed to fetch wishlist: $e');
    }
  }

  Future<Map<String, dynamic>?> getWishlistMediaDetail({
    required int mediaId,
  }) async {
    final String url =
        'https://mandapam.co/api/v1/customer/wish-list/detail/$mediaId';
    String? token = sharedPreferences.getString(AppConstants.token);

    print('REQUEST URL: $url');
    print('HEADERS: ${{
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    }}');

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      print('RESPONSE STATUS: ${response.statusCode}');
      print('RESPONSE HEADERS: ${response.headers}');
      print('RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'error': 'Server returned ${response.statusCode}'};
    } on TimeoutException {
      print('REQUEST TIMED OUT');
      return {'error': 'Request timed out'};
    } catch (e) {
      print('ERROR: $e');
      return {'error': 'Unexpected error occurred'};
    }
  }
}
