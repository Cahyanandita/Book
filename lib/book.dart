import 'dart:io';

class Book {
  final int? id;
  String title;
  String author;
  DateTime publishedDate;
  bool isAvailable;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.publishedDate,
    required this.isAvailable,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as int,
      title: json['title'] as String,
      author: json['author'] as String,
      publishedDate: DateTime.parse(
          json['published_date'] as String), // Konversi dari string ke DateTime
      isAvailable:
          json['is_available'] == null ? false : json['is_available'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'published_date': publishedDate.toIso8601String().split('T').first,
      'is_available': isAvailable,
    };
  }
}