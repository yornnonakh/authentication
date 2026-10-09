import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
export 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://trhsmnnwcgymxqqbucrj.supabase.co',
    authOptions: const FlutterAuthClientOptions(
      persistSession: true,
      autoRefreshToken: true,
    ),
    publishableKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRyaHNtbm53Y2d5bXhxcWJ1Y3JqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE0MjkzNzQsImV4cCI6MjEwNzAwNTM3NH0.Z-39oOCx7iIgc-6BccDp4XVNmOr9-YbgOG8luHKP-Y4',
  );
  runApp(const ProviderScope(child: MyApp()));
}
