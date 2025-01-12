import 'package:flutter/material.dart';
import 'package:book/books_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Supabase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: '#',
    anonKey:
        '#',
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BooksPage(),
    );
  }
}
