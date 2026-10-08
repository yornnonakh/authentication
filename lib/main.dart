// lib/main.dart
import 'package:authentication/feature/auth/screen/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//passwrod re : re_123456

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://trhsmnnwcgymxqqbucrj.supabase.co',          // e.g. https://xxxxx.supabase.co
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRyaHNtbm53Y2d5bXhxcWJ1Y3JqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE0MjkzNzQsImV4cCI6MjEwNzAwNTM3NH0.Z-39oOCx7iIgc-6BccDp4XVNmOr9-YbgOG8luHKP-Y4',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client; // convenient global

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insightlancer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      ),
      home: const SignInScreen(),
    );
  }
}