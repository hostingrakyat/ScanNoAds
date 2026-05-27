class ScanDocument {
  ScanDocument({
    required this.id,
    required this.title,
    required this.type,
    required this.files,
    required this.thumb,
    required this.pageCount,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String type; // 'pdf' | 'image'
  final List<String> files;
  final String thumb;
  final int pageCount;
  final DateTime createdAt;

  bool get isPdf => type == 'pdf';

  ScanDocument copyWith({String? title}) => ScanDocument(
        id: id,
        title: title ?? this.title,
        type: type,
        files: files,
        thumb: thumb,
        pageCount: pageCount,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'files': files,
        'thumb': thumb,
        'pageCount': pageCount,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ScanDocument.fromJson(Map<String, dynamic> json) => ScanDocument(
        id: json['id'] as String,
        title: json['title'] as String,
        type: json['type'] as String,
        files: (json['files'] as List).map((e) => e as String).toList(),
        thumb: json['thumb'] as String,
        pageCount: json['pageCount'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
