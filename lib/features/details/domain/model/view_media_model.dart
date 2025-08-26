class UserDetails {
  final int userId;
  final String userType;
  final String name;
  final String phone;
  final String? image;
  final String? imageFullUrl;
  final String? address;
  final String? latitude;
  final String? longitude;

  UserDetails({
    required this.userId,
    required this.userType,
    required this.name,
    required this.phone,
    this.image,
    this.imageFullUrl,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      userId: json['user_id'] as int,
      userType: json['usertype'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      image: json['image'],
      imageFullUrl: json['image_full_url'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

class MediaItem {
  final int mediaId;
  final String mediaType;
  final String filePath;
  final String? imageFullUrl;
  final String? title;
  final String? description;
  final int? decoratorId;

  MediaItem({
    required this.mediaId,
    required this.mediaType,
    required this.filePath,
    this.imageFullUrl,
    this.title,
    this.description,
    this.decoratorId,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      mediaId: json['media_id'] as int,
      mediaType: json['media_type'] as String,
      filePath: json['file_path'] as String,
      imageFullUrl: json['image_full_url'],
      title: json['title'],
      description: json['description'],
      decoratorId: json['decorator_id'],
    );
  }
}

class DecoratorMedia {
  final int batchId;
  final int eventId;
  final String eventTitle;
  final List<MediaItem> media;

  DecoratorMedia({
    required this.batchId,
    required this.eventId,
    required this.eventTitle,
    required this.media,
  });

  factory DecoratorMedia.fromJson(Map<String, dynamic> json) {
    return DecoratorMedia(
      batchId: json['batch_id'] as int,
      eventId: json['event_id'] as int,
      eventTitle: json['event_title'] as String,
      media: (json['media'] as List)
          .map((mediaJson) => MediaItem.fromJson(mediaJson))
          .toList(),
    );
  }
}

class MediaResponse {
  final String message;
  final UserDetails userDetails;
  final List<DecoratorMedia> data;

  MediaResponse({
    required this.message,
    required this.userDetails,
    required this.data,
  });

  factory MediaResponse.fromJson(Map<String, dynamic> json) {
    return MediaResponse(
      message: json['message'] as String,
      userDetails: UserDetails.fromJson(json['user_details']),
      data: (json['data'] as List)
          .map((decoratorJson) => DecoratorMedia.fromJson(decoratorJson))
          .toList(),
    );
  }
}