import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../domain/models/auth_event.dart';
import '../../domain/repositories/auth_repository.dart';
import '../repositories/supabase_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => SupabaseAuthRepository(ref.watch(supabaseClientProvider)),
);

final authEventsProvider = StreamProvider.autoDispose<AuthEvent>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges,
);
