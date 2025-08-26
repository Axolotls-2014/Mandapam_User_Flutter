class MediaResponse {
  final String message;
  final UserDetails userDetails;
  final List<MediaData> data;

  MediaResponse({
    required this.message,
    required this.userDetails,
    required this.data,
  });

  factory MediaResponse.fromJson(Map<String, dynamic> json) {
    return MediaResponse(
      message: json['message'],
      userDetails: UserDetails.fromJson(json['user_details']),
      data: (json['data'] as List).map((e) => MediaData.fromJson(e)).toList(),
    );
  }
}

class UserDetails {
  final int userId;
  final String usertype;
  final String name;
  final String phone;
  final String image;
  final String imageFullUrl;
  final String address;
  final String latitude;
  final String longitude;

  UserDetails({
    required this.userId,
    required this.usertype,
    required this.name,
    required this.phone,
    required this.image,
    required this.imageFullUrl,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      userId: json['user_id'],
      usertype: json['usertype'],
      name: json['name'],
      phone: json['phone'],
      image: json['image'],
      imageFullUrl: json['image_full_url'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

class MediaData {
  final int batchId;
  final int eventId;
  final String eventTitle;
  final List<MediaItem> media;
  final UserDetails user;

  MediaData({
    required this.batchId,
    required this.eventId,
    required this.eventTitle,
    required this.media,
    required this.user,
  });

  factory MediaData.fromJson(Map<String, dynamic> json) {
    return MediaData(
      batchId: json['batch_id'],
      eventId: json['event_id'],
      eventTitle: json['event_title'],
      media: (json['media'] as List).map((e) => MediaItem.fromJson(e)).toList(),
      user: UserDetails.fromJson(json['user']),
    );
  }
}

class MediaItem {
  final int mediaId;
  final String mediaType;
  final String filePath;
  final String imageFullUrl;
  final String? title;
  final String? description;

  MediaItem({
    required this.mediaId,
    required this.mediaType,
    required this.filePath,
    required this.imageFullUrl,
    this.title,
    this.description,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      mediaId: json['media_id'],
      mediaType: json['media_type'],
      filePath: json['file_path'],
      imageFullUrl: json['image_full_url'],
      title: json['title'],
      description: json['description'],
    );
  }
}