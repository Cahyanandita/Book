import 'package:flutter/material.dart';
import 'package:book/book.dart';
import 'package:book/book_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  final textController = TextEditingController();
  final authorController = TextEditingController();
  final dateController = TextEditingController();
  final _bookDatabase = BookDatabase();

  //search
  bool isSearching = false;

  //filter
  bool isFilteredByAvailable = false;

  final searchController = TextEditingController();

  // Book database

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search books',
                  border: InputBorder.none,
                ),
                autofocus: true,
                onChanged: (value) => setState(() {}),
              )
            : const Text('Books'),
        actions: [
          IconButton(
            onPressed: () => setState(() => isSearching = !isSearching),
            icon: Icon(isSearching ? Icons.close : Icons.search),
          ),
          IconButton(
            onPressed: () =>
                setState(() => isFilteredByAvailable = !isFilteredByAvailable),
            icon: Icon(
                isFilteredByAvailable ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      body: StreamBuilder<List<Book>>(
        stream: _bookDatabase.getBooksStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No books available.'));
          }

          final books = snapshot.data!;

          final searchedBooks = searchController.text.isEmpty
              ? books
              : books
                  .where((book) => book.title
                      .toLowerCase()
                      .contains(searchController.text.toLowerCase()))
                  .toList();

          // Filter by availability
          final filteredBooks = isFilteredByAvailable
              ? searchedBooks.where((book) => book.isAvailable).toList()
              : searchedBooks;

          if (filteredBooks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(searchController.text.isEmpty
                      ? 'No books found'
                      : 'No results found'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: addNewBook,
                    child: const Text('Add a book'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredBooks.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(filteredBooks[index].title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(filteredBooks[index].author),
                  const SizedBox(height: 4),
                  Text(
                    'Published: ${filteredBooks[index].publishedDate.toLocal().toString().split(' ')[0]}', // Menampilkan tanggal dalam format YYYY-MM-DD
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Availability: ${filteredBooks[index].isAvailable ? 'Available' : 'Not Available'}',
                    style: const TextStyle(color: Colors.grey),
                  )
                ],
              ),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => editBook(filteredBooks[index]),
                      icon: const Icon(Icons.edit, color: Colors.green),
                    ),
                    IconButton(
                      onPressed: () => deleteBook(filteredBooks[index]),
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBook,
        child: const Icon(Icons.add),
      ),
    );
  }

  void addNewBook() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Book'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(hintText: 'Enter your book title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(hintText: 'Enter your author'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: dateController,
              readOnly: true,
              decoration: const InputDecoration(hintText: 'Select a date'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  dateController.text = pickedDate
                      .toIso8601String()
                      .split('T')
                      .first; // Format YYYY-MM-DD
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty &&
                  RegExp(r'^\d{4}-\d{2}-\d{2}$')
                      .hasMatch(dateController.text)) {
                try {
                  final book = Book(
                    title: textController.text,
                    author: authorController.text,
                    publishedDate: DateTime.parse(dateController.text),
                    isAvailable: false,
                  );

                  _bookDatabase.insertBook(book);

                  Navigator.pop(context);
                  textController.clear();
                  authorController.clear();
                  dateController.clear();
                } catch (e) {
                  print('Error: $e');
                }
              } else {
                print('Invalid date format. Use YYYY-MM-DD.');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void editBook(Book book) {
    textController.text = book.title;
    authorController.text = book.author;
    dateController.text = book.publishedDate.toIso8601String().split('T').first;
    bool isAvailable = book.isAvailable;

    // edit
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Book'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Input untuk judul buku
            TextField(
              controller: textController,
              decoration: const InputDecoration(labelText: 'Book Title'),
            ),
            const SizedBox(height: 10),
            // Input untuk nama pengarang
            TextField(
              controller: authorController,
              decoration: const InputDecoration(labelText: 'Author'),
            ),
            const SizedBox(height: 10),
            // Input untuk tanggal terbit
            TextField(
              controller: dateController,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Published Date'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: book.publishedDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  dateController.text = pickedDate
                      .toIso8601String()
                      .split('T')
                      .first; // Format YYYY-MM-DD
                }
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Available'),
                Switch(
                  value: isAvailable,
                  onChanged: (value) {
                    setState(() {
                      isAvailable = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              book.title = textController.text;
              book.author = authorController.text;
              book.publishedDate = DateTime.parse(dateController.text);
              book.isAvailable = isAvailable;

              await _bookDatabase.updateBook(book);

              Navigator.pop(context);
              textController.clear();
              authorController.clear();
              dateController.clear();
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              textController.clear();
              authorController.clear();
              dateController.clear();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void deleteBook(Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text(
            'Are you sure you want to delete this book?\n\n"${book.title}"'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _bookDatabase.deleteBook(book.id!);
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void toggleAvailable(Book book) {
    book.isAvailable = !book.isAvailable;
    _bookDatabase.updateBook(book);
  }
}