import 'package:flutter/material.dart';
import 'package:book/books_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Supabase setup
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://jpmddqjjetfozsiqfdwg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpwbWRkcWpqZXRmb3pzaXFmZHdnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI5NTczOTAsImV4cCI6MjA0ODUzMzM5MH0.-56bO25uLShUo3mRTB1M69ZVuwxFfGvoLyLw_4Z9_mQ',
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