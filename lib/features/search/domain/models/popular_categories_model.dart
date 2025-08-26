// class PopularCategoryModel {
//   int? id;
//   String? name;
//   String? image;
//   int? parentId;
//   int? position;
//   int? status;
//   String? createdAt;
//   String? updatedAt;
//   int? priority;
//   int? moduleId;
//   int? featured;
//   String? imageFullUrl;
//
//   PopularCategoryModel({
//     this.id,
//     this.name,
//     this.image,
//     this.parentId,
//     this.position,
//     this.status,
//     this.createdAt,
//     this.updatedAt,
//     this.priority,
//     this.moduleId,
//     this.featured,
//     this.imageFullUrl,
//   });
//
//   PopularCategoryModel.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     image = json['image'];
//     parentId = json['parent_id'];
//     position = json['position'];
//     status = json['status'];
//     createdAt = json['created_at'];
//     updatedAt = json['updated_at'];
//     priority = json['priority'];
//     moduleId = json['module_id'];
//     featured = json['featured'];
//     imageFullUrl = json['image_full_url'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['name'] = name;
//     data['image'] = image;
//     data['parent_id'] = parentId;
//     data['position'] = position;
//     data['status'] = status;
//     data['created_at'] = createdAt;
//     data['updated_at'] = updatedAt;
//     data['priority'] = priority;
//     data['module_id'] = moduleId;
//     data['featured'] = featured;
//     data['image_full_url'] = imageFullUrl;
//     return data;
//   }
// }

class PopularCategoryModel {
  int? id;
  String? title;
  String? image;
  bool? status;
  int? data;
  String? createdAt;
  String? updatedAt;
  int? moduleId;
  String? createdBy;
  int? popular;
  String? imageFullUrl;
  List<Storage>? storage;
  List<Translation>? translations;

  PopularCategoryModel({
    this.id,
    this.title,
    this.image,
    this.status,
    this.data,
    this.createdAt,
    this.updatedAt,
    this.moduleId,
    this.createdBy,
    this.popular,
    this.imageFullUrl,
    this.storage,
    this.translations,
  });

  PopularCategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
    status = json['status'];
    data = json['data'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    moduleId = json['module_id'];
    createdBy = json['created_by'];
    popular = json['popular'];
    imageFullUrl = json['image_full_url'];
    if (json['storage'] != null) {
      storage = <Storage>[];
      json['storage'].forEach((v) {
        storage!.add(Storage.fromJson(v));
      });
    }
    if (json['translations'] != null) {
      translations = <Translation>[];
      json['translations'].forEach((v) {
        translations!.add(Translation.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['image'] = image;
    data['status'] = status;
    data['data'] = data;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['module_id'] = moduleId;
    data['created_by'] = createdBy;
    data['popular'] = popular;
    data['image_full_url'] = imageFullUrl;
    if (storage != null) {
      data['storage'] = storage!.map((v) => v.toJson()).toList();
    }
    if (translations != null) {
      data['translations'] = translations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Storage {
  int? id;
  String? dataType;
  String? dataId;
  String? key;
  String? value;
  String? createdAt;
  String? updatedAt;

  Storage({
    this.id,
    this.dataType,
    this.dataId,
    this.key,
    this.value,
    this.createdAt,
    this.updatedAt,
  });

  Storage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dataType = json['data_type'];
    dataId = json['data_id'];
    key = json['key'];
    value = json['value'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['data_type'] = dataType;
    data['data_id'] = dataId;
    data['key'] = key;
    data['value'] = value;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Translation {
  int? id;
  String? translationableType;
  int? translationableId;
  String? locale;
  String? key;
  String? value;
  String? createdAt;
  String? updatedAt;

  Translation({
    this.id,
    this.translationableType,
    this.translationableId,
    this.locale,
    this.key,
    this.value,
    this.createdAt,
    this.updatedAt,
  });

  Translation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    translationableType = json['translationable_type'];
    translationableId = json['translationable_id'];
    locale = json['locale'];
    key = json['key'];
    value = json['value'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['translationable_type'] = translationableType;
    data['translationable_id'] = translationableId;
    data['locale'] = locale;
    data['key'] = key;
    data['value'] = value;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
