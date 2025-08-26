//
// class CategoryModel {
//   int? _id;
//   String? _name;
//   int? _parentId;
//   int? _position;
//   String? _createdAt;
//   String? _updatedAt;
//   String? _imageFullUrl;
//
//   CategoryModel(
//     {int? id,
//     String? name,
//     int? parentId,
//     int? position,
//     String? createdAt,
//     String? updatedAt,
//     String? imageFullUrl}) {
//     _id = id;
//     _name = name;
//     _parentId = parentId;
//     _position = position;
//     _createdAt = createdAt;
//     _updatedAt = updatedAt;
//     _imageFullUrl = imageFullUrl;
//   }
//
//   int? get id => _id;
//   String? get name => _name;
//   int? get parentId => _parentId;
//   int? get position => _position;
//   String? get createdAt => _createdAt;
//   String? get updatedAt => _updatedAt;
//   String? get imageFullUrl => _imageFullUrl;
//
//   CategoryModel.fromJson(Map<String, dynamic> json) {
//     _id = json['id'];
//     _name = json['name'];
//     _parentId = json['parent_id'];
//     _position = json['position'];
//     _createdAt = json['created_at'];
//     _updatedAt = json['updated_at'];
//     _imageFullUrl = json['image_full_url'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = _id;
//     data['name'] = _name;
//     data['parent_id'] = _parentId;
//     data['position'] = _position;
//     data['created_at'] = _createdAt;
//     data['updated_at'] = _updatedAt;
//     data['image_full_url'] = _imageFullUrl;
//
//     return data;
//   }
// }

class CategoryModel {
  int? _id;
  String? _title;
  String? _image;
  bool? _status;
  int? _data;
  String? _createdAt;
  String? _updatedAt;
  int? _moduleId;
  String? _createdBy;
  int? _popular;
  String? _imageFullUrl;
  List<Storage>? _storage;
  List<Translations>? _translations;

  CategoryModel({
    int? id,
    String? title,
    String? image,
    bool? status,
    int? data,
    String? createdAt,
    String? updatedAt,
    int? moduleId,
    String? createdBy,
    int? popular,
    String? imageFullUrl,
    List<Storage>? storage,
    List<Translations>? translations,
  }) {
    _id = id;
    _title = title;
    _image = image;
    _status = status;
    _data = data;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _moduleId = moduleId;
    _createdBy = createdBy;
    _popular = popular;
    _imageFullUrl = imageFullUrl;
    _storage = storage;
    _translations = translations;
  }

  int? get id => _id;
  String? get title => _title;
  String? get image => _image;
  bool? get status => _status;
  int? get data => _data;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  int? get moduleId => _moduleId;
  String? get createdBy => _createdBy;
  int? get popular => _popular;
  String? get imageFullUrl => _imageFullUrl;
  List<Storage>? get storage => _storage;
  List<Translations>? get translations => _translations;

  CategoryModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _title = json['title'];
    _image = json['image'];
    _status = json['status'];
    _data = json['data'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _moduleId = json['module_id'];
    _createdBy = json['created_by'];
    _popular = json['popular'];
    _imageFullUrl = json['image_full_url'];

    if (json['storage'] != null) {
      _storage = json['storage']
          .map<Storage>((v) => Storage.fromJson(v))
          .toList();
    }

    if (json['translations'] != null) {
      _translations = json['translations']
          .map<Translations>((v) => Translations.fromJson(v))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['title'] = _title;
    data['image'] = _image;
    data['status'] = _status;
    data['data'] = _data;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['module_id'] = _moduleId;
    data['created_by'] = _createdBy;
    data['popular'] = _popular;
    data['image_full_url'] = _imageFullUrl;
    if (_storage != null) {
      data['storage'] = _storage!.map((v) => v.toJson()).toList();
    }
    if (_translations != null) {
      data['translations'] = _translations!.map((v) => v.toJson()).toList();
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

class Translations {
  int? id;
  String? translationableType;
  int? translationableId;
  String? locale;
  String? key;
  String? value;
  String? createdAt;
  String? updatedAt;

  Translations({
    this.id,
    this.translationableType,
    this.translationableId,
    this.locale,
    this.key,
    this.value,
    this.createdAt,
    this.updatedAt,
  });

  Translations.fromJson(Map<String, dynamic> json) {
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
