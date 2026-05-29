class ArticleModel {

  final String title;
  final String abstract;
  final String author;
  final String journal;
  final String year;
  final int citationCount;
  final String pdfUrl;
  final String source;

  ArticleModel({

    required this.title,
    required this.abstract,
    required this.author,
    required this.journal,
    required this.year,
    required this.citationCount,
    required this.pdfUrl,
    required this.source,
  });

  factory ArticleModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return ArticleModel(

      title:
          json['title']?.toString() ?? '',

      abstract:
          json['abstract']?.toString() ?? '',

      author:
          json['author']?.toString() ?? '',

      journal:
          json['journal']?.toString() ?? '',

      year:
          json['year']?.toString() ?? '',

      citationCount:
          int.tryParse(
            json['citation_count']
                .toString(),
          ) ??
          0,

      pdfUrl:
          json['pdf_url']?.toString() ?? '',

      source:
          json['source']?.toString() ?? '',
    );
  }
}