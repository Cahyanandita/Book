import 'package:book/book.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookDatabase {
  // Instantiate new database object
  final database = Supabase.instance.client.from('books');

  // Insert
  Future<void> insertBook(Book book) async {
    await database.insert(book.toJson());
  }

  // Get
  Stream<List<Book>> getBooksStream() {
    return database.stream(primaryKey: ['id']).map(
        (data) => data.map((json) => Book.fromJson(json)).toList());
  }

  // Delete
  Future<void> deleteBook(int id) async {
    await database.delete().eq('id', id);
  }

  // Update
  Future<void> updateBook(Book book) async {
    await database.update(book.toJson()).eq('id', book.id!);
  }

  // Update the availability
  Future<void> updateBookAvailability(int bookId, bool isAvailable) async {
    await database
        .update({'is_available': isAvailable}) // Update status isAvailable
        .eq('id', bookId); // Pastikan berdasarkan id buku
  }
}