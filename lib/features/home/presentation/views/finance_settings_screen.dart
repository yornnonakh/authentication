import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../view_models/data_controls_view_model.dart';
import '../view_models/expense_view_model.dart';
import '../widgets/finance_widgets.dart';

class FinanceSettingsScreen extends ConsumerWidget {
  const FinanceSettingsScreen({super.key});
  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset all finance data?'),
        content: const Text(
          'This permanently removes all transactions and monthly budgets for your account on this device. Your profile stays available.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (proceed != true || !context.mounted) return;
    final confirmation = await showDialog<String>(
      context: context,
      builder: (_) => const _ResetConfirmation(),
    );
    if (confirmation == 'RESET' && context.mounted) {
      await ref.read(dataControlsProvider.notifier).reset(confirmation!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeModeProvider);
    final controls = ref.watch(dataControlsProvider);
    final tracker = ref.watch(expenseViewModelProvider);
    final colors = Theme.of(context).colorScheme;
    ref.listen(dataControlsProvider, (previous, next) {
      final message = next.error ?? next.message;
      if (message != null &&
          message != (previous?.error ?? previous?.message)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });
    return SingleChildScrollView(
      key: const PageStorageKey('settings-scroll'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Settings',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Your preferences and personal data',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: 28),
          FinanceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.palette_outlined, color: colors.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Appearance',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<ThemeMode>(
                  key: ValueKey(theme),
                  initialValue: theme,
                  decoration: const InputDecoration(labelText: 'Theme'),
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System default'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                  onChanged: (value) async {
                    final saved = await ref
                        .read(themeModeProvider.notifier)
                        .select(value!);
                    if (!saved && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Theme applied. Unable to save the preference for next launch.',
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'System default follows your device’s light or dark appearance.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FinanceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.storage_outlined, color: colors.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Data controls',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${tracker.value?.transactions.length ?? 0} transactions · Stored on this device',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                Builder(
                  builder: (buttonContext) => OutlinedButton.icon(
                    onPressed: controls.busy || !tracker.hasValue
                        ? null
                        : () {
                            final box =
                                buttonContext.findRenderObject() as RenderBox;
                            ref
                                .read(dataControlsProvider.notifier)
                                .export(
                                  box.localToGlobal(Offset.zero) & box.size,
                                );
                          },
                    icon: const Icon(Icons.ios_share_rounded),
                    label: const Text('Export Data to CSV'),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Share or save all transactions as a CSV file, including categories and notes.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const Divider(height: 36),
                OutlinedButton.icon(
                  onPressed: controls.busy || !tracker.hasValue
                      ? null
                      : () => _reset(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                    side: BorderSide(
                      color: colors.error.withValues(alpha: 0.4),
                    ),
                  ),
                  icon: const Icon(Icons.delete_forever_outlined),
                  label: const Text('Reset All Data'),
                ),
                if (controls.busy)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const FinanceCard(
            child: FinanceEmptyState(
              title: 'Local by design',
              icon: Icons.phonelink_lock_rounded,
              message:
                  'Finance records are saved per account on this device. Export a copy for backup. The receipt scanner uses mock data.',
            ),
          ),
        ],
      ),
    );
  }
}

class _ResetConfirmation extends StatefulWidget {
  const _ResetConfirmation();
  @override
  State<_ResetConfirmation> createState() => _ResetConfirmationState();
}

class _ResetConfirmationState extends State<_ResetConfirmation> {
  final _confirmation = TextEditingController();
  @override
  void dispose() {
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Confirm permanent reset'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Type RESET to confirm. This action cannot be undone.'),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmation,
          onChanged: (_) => setState(() {}),
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Type RESET'),
          textCapitalization: TextCapitalization.characters,
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
        onPressed: _confirmation.text == 'RESET'
            ? () => Navigator.pop(context, 'RESET')
            : null,
        child: const Text('Reset permanently'),
      ),
    ],
  );
}
