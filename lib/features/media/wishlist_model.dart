// Add these model classes at the top of your file or in a separate models file

class WishlistMedia {
  final int wishlistId;
  final int mediaId;
  final String title;
  final String mediaType;
  final String imageUrl;
  final int eventId;
  final String eventTitle;
  final int decoratorId;
  final String decoratorName;
  final String? decoratorImage;
  final String? description;

  WishlistMedia({
    required this.wishlistId,
    required this.mediaId,
    required this.title,
    required this.mediaType,
    required this.imageUrl,
    required this.eventId,
    required this.eventTitle,
    required this.decoratorId,
    required this.decoratorName,
    this.decoratorImage,
    this.description,
  });

  factory WishlistMedia.fromWishlistItem(WishlistItem item) {
    return WishlistMedia(
      wishlistId: item.wishlistId,
      mediaId: item.mediaId ?? 0,
      title: item.mediaTitle ?? 'Untitled',
      mediaType: item.mediaType ?? 'photo',
      imageUrl: item.imageFullUrl ?? '',
      eventId: item.eventId ?? 0,
      eventTitle: item.eventTitle ?? 'No Event',
      decoratorId: item.decorator.userId ?? 0,
      decoratorName: '${item.decorator.firstName ?? ''} ${item.decorator.lastName ?? ''}'.trim(),
      decoratorImage: item.decorator.imageFullUrl,
      description: item.description,
    );
  }
}

class WishlistResponse {
  final String message;
  final List<WishlistItem> wishlist;

  WishlistResponse({
    required this.message,
    required this.wishlist,
  });

  factory WishlistResponse.fromJson(Map<String, dynamic> json) {
    return WishlistResponse(
      message: json['message'],
      wishlist: List<WishlistItem>.from(
        json['wishlist'].map((x) => WishlistItem.fromJson(x)),
      ),
    );
  }
}

class WishlistItem {
  final int wishlistId;
  final int? mediaId;
  final String? mediaTitle;
  final String? mediaType;
  final String? imageFullUrl;
  final int? eventId;
  final String? eventTitle;
  final String? description;
  final Decorator decorator;

  WishlistItem({
    required this.wishlistId,
    this.mediaId,
    this.mediaTitle,
    this.mediaType,
    this.imageFullUrl,
    this.eventId,
    this.eventTitle,
    this.description,
    required this.decorator,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      wishlistId: json['wishlist_id'] ?? 0,
      mediaId: _parseInt(json['media_id']),
      mediaTitle: json['media_title'],
      mediaType: json['media_type'],
      imageFullUrl: json['image_full_url'],
      eventId: _parseInt(json['event_id']),
      eventTitle: json['event_title'],
      description: json['description'],
      decorator: Decorator.fromJson(json['Decorator'] ?? {}),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class Decorator {
  final int? userId;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? aboutUs;
  final String? image;
  final String? imageFullUrl;

  Decorator({
    this.userId,
    this.firstName,
    this.lastName,
    this.phone,
    this.aboutUs,
    this.image,
    this.imageFullUrl,
  });

  factory Decorator.fromJson(Map<String, dynamic> json) {
    return Decorator(
      userId: json['user_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      aboutUs: json['about_us'],
      image: json['image'],
      imageFullUrl: json['image_full_url'],
    );
  }
}
