// To parse this JSON data, do
//
//     final mediaModel = mediaModelFromJson(jsonString);

import 'dart:convert';

MediaModel mediaModelFromJson(String str) =>
    MediaModel.fromJson(json.decode(str));

// String mediaModelToJson(MediaModel data) => json.encode(data.toJson());

class MediaModel {
  String? message;
  UserDetails? userDetails;
  List<Datum>? data;
  // Map<String, List<Datum>>? data;

  MediaModel({
    this.message,
    this.userDetails,
    this.data,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) => MediaModel(
        message: json["message"],
        userDetails: json["user_details"] == null
            ? null
            : UserDetails.fromJson(json["user_details"]),
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  // factory MediaModel.fromJson(Map<String, dynamic> json) => MediaModel(
  //     message: json["message"],
  //     userDetails: json["user_details"] == null
  //         ? null
  //         : UserDetails.fromJson(json["user_details"]),
  //     data: json["data"] == null
  //         ? {}
  //         : json["data"].fold<Map<String, List<Datum>>>({}, (map, item) {
  //             String eventTitle = item["event_title"] ?? "Unknown";
  //             Datum datum = Datum.fromJson(item);
  //             if (!map.containsKey(eventTitle)) {
  //               map[eventTitle] = [];
  //             }
  //             map[eventTitle]!.add(datum);
  //             return map;
  //           }),
  //   );

  Map<String, dynamic> toJson() => {
        "message": message,
        "user_details": userDetails?.toJson(),
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  int? batchId;
  int? eventId;
  String? eventTitle;
  List<Media>? media;

  Datum({
    this.batchId,
    this.eventId,
    this.eventTitle,
    this.media,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        batchId: json["batch_id"],
        eventId: json["event_id"],
        eventTitle: json["event_title"],
        media: json["media"] == null
            ? []
            : List<Media>.from(json["media"]!.map((x) => Media.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "batch_id": batchId,
        "event_id": eventId,
        "event_title": eventTitle,
        "media": media == null
            ? []
            : List<dynamic>.from(media!.map((x) => x.toJson())),
      };
}

class Media {
  int? mediaId;
  String? mediaType;
  String? filePath;
  String? imageFullUrl;

  Media({
    this.mediaId,
    this.mediaType,
    this.filePath,
    this.imageFullUrl,
  });

  factory Media.fromJson(Map<String, dynamic> json) => Media(
        mediaId: json["media_id"],
        mediaType: json["media_type"],
        filePath: json["file_path"],
        imageFullUrl: json["image_full_url"],
      );

  Map<String, dynamic> toJson() => {
        "media_id": mediaId,
        "media_type": mediaType,
        "file_path": filePath,
        "image_full_url": imageFullUrl,
      };
}

class UserDetails {
  int? userId;
  String? usertype;
  String? name;
  String? phone;
  String? image;
  String? imageFullUrl;
  String? address;
  String? latitude;
  String? longitude;

  UserDetails({
    this.userId,
    this.usertype,
    this.name,
    this.phone,
    this.image,
    this.imageFullUrl,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
        userId: json["user_id"],
        usertype: json["usertype"],
        name: json["name"],
        phone: json["phone"],
        image: json["image"],
        imageFullUrl: json["image_full_url"],
        address: json["address"],
        latitude: json["latitude"],
        longitude: json["longitude"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "usertype": usertype,
        "name": name,
        "phone": phone,
        "image": image,
        "image_full_url": imageFullUrl,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
      };
}
