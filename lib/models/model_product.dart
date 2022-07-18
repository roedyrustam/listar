import 'package:listar/models/model.dart';

class ProductModel {
  final int id;
  final String title;
  final ImageModel image;
  final CategoryModel? category;
  final String createDate;
  final String dateEstablish;
  final double rate;
  final num numRate;
  final String rateText;
  final String status;
  bool favorite;
  final String address;
  final String zipCode;
  final String phone;
  final String fax;
  final String email;
  final String website;
  final String description;
  final String color;
  final String icon;
  final List<String> tags;
  final String priceMin;
  final String priceMax;
  final CategoryModel? country;
  final CategoryModel? city;
  final CategoryModel? state;
  final UserModel? author;
  final List<ImageModel> galleries;
  final List<CategoryModel> features;
  final List<ProductModel> related;
  final List<ProductModel> lastest;
  final List<OpenTimeModel> openHours;
  final LocationModel? location;
  final String link;
  final bool bookingUse;

  ProductModel({
    required this.id,
    required this.title,
    required this.image,
    required this.category,
    required this.createDate,
    required this.dateEstablish,
    required this.rate,
    required this.numRate,
    required this.rateText,
    required this.status,
    required this.favorite,
    required this.address,
    required this.zipCode,
    required this.phone,
    required this.fax,
    required this.email,
    required this.website,
    required this.description,
    required this.color,
    required this.icon,
    required this.tags,
    required this.priceMin,
    required this.priceMax,
    required this.country,
    this.city,
    this.state,
    this.author,
    required this.galleries,
    required this.features,
    required this.related,
    required this.lastest,
    required this.openHours,
    required this.location,
    required this.link,
    required this.bookingUse,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    UserModel? author;
    CategoryModel? category;
    LocationModel? location;

    CategoryModel? country;
    CategoryModel? state;
    CategoryModel? city;

    if (json['author'] != null) {
      author = UserModel.fromJson(json['author']);
    }
    if (json['category'] != null) {
      category = CategoryModel.fromJson(json['category']);
    }
    if (json['location'] != null && json['location']['country'] != null) {
      country = CategoryModel.fromJson(json['location']['country']);
    }
    if (json['location'] != null && json['location']['state'] != null) {
      state = CategoryModel.fromJson(json['location']['state']);
    }
    if (json['location'] != null && json['location']['city'] != null) {
      city = CategoryModel.fromJson(json['location']['city']);
    }
    if (json['latitude'] != null) {
      location = LocationModel.fromJson({
        "name": json['post_title'] ?? "",
        "latitude": json['latitude'] ?? 0.0,
        "longitude": json['longitude'] ?? 0.0
      });
    }

    final galleries = List.from(json['galleries'] ?? []).map((item) {
      return ImageModel.fromJson(item);
    }).toList();

    final listFeatures = List.from(json['features'] ?? []).map((item) {
      return CategoryModel.fromJson(item);
    }).toList();

    final listRelated = List.from(json['related'] ?? []).map((item) {
      return ProductModel.fromJson(item);
    }).toList();

    final listLastest = List.from(json['lastest'] ?? []).map((item) {
      return ProductModel.fromJson(item);
    }).toList();

    final listOpenHour = List.from(json['opening_hour'] ?? []).map((item) {
      return OpenTimeModel.fromJson(item);
    }).toList();

    final listTags = List.from(json['tags'] ?? []).map((item) {
      return item['name'] as String;
    }).toList();

    return ProductModel(
        id: int.tryParse(json['ID'].toString()) ?? 0,
        title: json['post_title'] ?? '',
        image: ImageModel.fromJson(json['image']),
        category: category,
        createDate: json['post_date'] ?? '',
        dateEstablish: json['date_establish'] ?? '',
        rate: double.tryParse('${json['rating_avg']}') ?? 0.0,
        numRate: json['rating_count'] ?? 0,
        rateText: json['post_status'] ?? '',
        status: json['status'] ?? '',
        favorite: json['wishlist'] ?? false,
        address: json['address'] ?? '',
        zipCode: json['zip_code'] ?? '',
        phone: json['phone'] ?? '',
        fax: json['fax'] ?? '',
        email: json['email'] ?? '',
        website: json['website'] ?? '',
        description: json['post_excerpt'] ?? '',
        color: json['color'] ?? '',
        icon: json['icon'] ?? '',
        tags: listTags,
        priceMin: json['price_min']?.toString() ?? '',
        priceMax: json['price_max']?.toString() ?? '',
        country: country,
        state: state,
        city: city,
        features: listFeatures,
        author: author,
        galleries: galleries,
        related: listRelated,
        lastest: listLastest,
        openHours: listOpenHour,
        location: location,
        link: json['guid'] ?? '',
        bookingUse: json['booking_use'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      "ID": id,
      "post_title": title,
      "image": {
        "id": 0,
        "full": {},
        "thumb": {},
      },
    };
  }
}
