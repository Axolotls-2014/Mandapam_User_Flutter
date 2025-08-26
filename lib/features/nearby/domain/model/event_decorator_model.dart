// To parse this JSON data, do
//
//     final eventDecoratorModel = eventDecoratorModelFromJson(jsonString);

import 'dart:convert';

EventDecoratorModel eventDecoratorModelFromJson(Map<String, dynamic> json) => EventDecoratorModel.fromJson(json);

String eventDecoratorModelToJson(EventDecoratorModel data) => json.encode(data.toJson());

class EventDecoratorModel {
    int? totalSize;
    dynamic limit;
    dynamic offset;
    List<User>? users;

    EventDecoratorModel({
        this.totalSize,
        this.limit,
        this.offset,
        this.users,
    });

    factory EventDecoratorModel.fromJson(Map<String, dynamic> json) => EventDecoratorModel(
        totalSize: json["total_size"],
        limit: json["limit"],
        offset: json["offset"],
        users: json["users"] == null ? [] : List<User>.from(json["users"]!.map((x) => User.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "total_size": totalSize,
        "limit": limit,
        "offset": offset,
        "users": users == null ? [] : List<dynamic>.from(users!.map((x) => x.toJson())),
    };
}

class User {
    int? id;
    String? fName;
    String? lName;
    String? phone;
    String? email;
    String? image;
    int? isPhoneVerified;
    dynamic emailVerifiedAt;
    DateTime? createdAt;
    DateTime? updatedAt;
    String? cmFirebaseToken;
    int? status;
    int? orderCount;
    dynamic loginMedium;
    dynamic socialId;
    int? zoneId;
    int? walletBalance;
    int? loyaltyPoint;
    String? refCode;
    CurrentLanguageKey? currentLanguageKey;
    dynamic refBy;
    dynamic tempToken;
    Usertype? usertype;
    int? moduleId;
    String? address;
    String? latitude;
    String? longitude;
    List<dynamic>? categoryIds;
    List<int>? ratings;
    int? avgRating;
    int? ratingCount;
    int? positiveRating;
    int? totalReviews;
    bool? isActive;
    bool? isVerified;
    bool? extraUserStatus;
    int? extraUserAmount;
    String? imageFullUrl;
    List<Storage>? storage;

    User({
        this.id,
        this.fName,
        this.lName,
        this.phone,
        this.email,
        this.image,
        this.isPhoneVerified,
        this.emailVerifiedAt,
        this.createdAt,
        this.updatedAt,
        this.cmFirebaseToken,
        this.status,
        this.orderCount,
        this.loginMedium,
        this.socialId,
        this.zoneId,
        this.walletBalance,
        this.loyaltyPoint,
        this.refCode,
        this.currentLanguageKey,
        this.refBy,
        this.tempToken,
        this.usertype,
        this.moduleId,
        this.address,
        this.latitude,
        this.longitude,
        this.categoryIds,
        this.ratings,
        this.avgRating,
        this.ratingCount,
        this.positiveRating,
        this.totalReviews,
        this.isActive,
        this.isVerified,
        this.extraUserStatus,
        this.extraUserAmount,
        this.imageFullUrl,
        this.storage,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        fName: json["f_name"],
        lName: json["l_name"],
        phone: json["phone"],
        email: json["email"],
        image: json["image"],
        isPhoneVerified: json["is_phone_verified"],
        emailVerifiedAt: json["email_verified_at"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        cmFirebaseToken: json["cm_firebase_token"],
        status: json["status"],
        orderCount: json["order_count"],
        loginMedium: json["login_medium"],
        socialId: json["social_id"],
        zoneId: json["zone_id"],
        walletBalance: json["wallet_balance"],
        loyaltyPoint: json["loyalty_point"],
        refCode: json["ref_code"],
        currentLanguageKey: currentLanguageKeyValues.map[json["current_language_key"]]!,
        refBy: json["ref_by"],
        tempToken: json["temp_token"],
        usertype: usertypeValues.map[json["usertype"]]!,
        moduleId: json["module_id"],
        address: json["address"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        categoryIds: json["category_ids"] == null ? [] : List<dynamic>.from(json["category_ids"]!.map((x) => x)),
        ratings: json["ratings"] == null ? [] : List<int>.from(json["ratings"]!.map((x) => x)),
        avgRating: json["avg_rating"],
        ratingCount: json["rating_count"],
        positiveRating: json["positive_rating"],
        totalReviews: json["total_reviews"],
        isActive: json["is_active"],
        isVerified: json["is_verified"],
        extraUserStatus: json["extra_user_status"],
        extraUserAmount: json["extra_user_amount"],
        imageFullUrl: json["image_full_url"],
        storage: json["storage"] == null ? [] : List<Storage>.from(json["storage"]!.map((x) => Storage.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "f_name": fName,
        "l_name": lName,
        "phone": phone,
        "email": email,
        "image": image,
        "is_phone_verified": isPhoneVerified,
        "email_verified_at": emailVerifiedAt,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "cm_firebase_token": cmFirebaseToken,
        "status": status,
        "order_count": orderCount,
        "login_medium": loginMedium,
        "social_id": socialId,
        "zone_id": zoneId,
        "wallet_balance": walletBalance,
        "loyalty_point": loyaltyPoint,
        "ref_code": refCode,
        "current_language_key": currentLanguageKeyValues.reverse[currentLanguageKey],
        "ref_by": refBy,
        "temp_token": tempToken,
        "usertype": usertypeValues.reverse[usertype],
        "module_id": moduleId,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "category_ids": categoryIds == null ? [] : List<dynamic>.from(categoryIds!.map((x) => x)),
        "ratings": ratings == null ? [] : List<dynamic>.from(ratings!.map((x) => x)),
        "avg_rating": avgRating,
        "rating_count": ratingCount,
        "positive_rating": positiveRating,
        "total_reviews": totalReviews,
        "is_active": isActive,
        "is_verified": isVerified,
        "extra_user_status": extraUserStatus,
        "extra_user_amount": extraUserAmount,
        "image_full_url": imageFullUrl,
        "storage": storage == null ? [] : List<dynamic>.from(storage!.map((x) => x.toJson())),
    };
}

enum CurrentLanguageKey {
    EN
}

final currentLanguageKeyValues = EnumValues({
    "en": CurrentLanguageKey.EN
});

class Storage {
    int? id;
    String? dataType;
    String? dataId;
    String? key;
    String? value;
    DateTime? createdAt;
    DateTime? updatedAt;

    Storage({
        this.id,
        this.dataType,
        this.dataId,
        this.key,
        this.value,
        this.createdAt,
        this.updatedAt,
    });

    factory Storage.fromJson(Map<String, dynamic> json) => Storage(
        id: json["id"],
        dataType: json["data_type"],
        dataId: json["data_id"],
        key: json["key"],
        value: json["value"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "data_type": dataType,
        "data_id": dataId,
        "key": key,
        "value": value,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}

enum Usertype {
    DECORATOR,
    USER
}

final usertypeValues = EnumValues({
    "Decorator": Usertype.DECORATOR,
    "User": Usertype.USER
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
