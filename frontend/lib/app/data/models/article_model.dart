class ArticleModel {

  final String title;

  final String description;

  final String category;

  final String image;

  final String url;

  ArticleModel({

    required this.title,

    required this.description,

    required this.category,

    required this.image,

    required this.url,
  });

  factory ArticleModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return ArticleModel(

      title:
          json['title'] ?? '',

      description:
          json['description'] ?? '',

      category:
          json['category'] ?? '',

      image:
          json['image'] ??
          json['image_url'] ??
          '',

      url:
          json['url'] ?? '',
    );
  }
}