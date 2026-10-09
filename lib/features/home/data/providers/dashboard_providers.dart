import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/dashboard_repository.dart';
import '../repositories/sample_dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => const SampleDashboardRepository(),
);
