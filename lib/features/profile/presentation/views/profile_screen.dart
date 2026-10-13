import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/view_models/auth_feedback.dart';
import '../../../auth/presentation/view_models/logout_view_model.dart';
import '../../../auth/presentation/widgets/auth_feedback_snackbar.dart';
import '../../../home/presentation/view_models/dashboard_navigation_view_model.dart';
import '../../../home/presentation/widgets/finance_widgets.dart';
import '../../domain/models/user_profile.dart';
import '../view_models/profile_state.dart';
import '../view_models/profile_view_model.dart';
import '../widgets/profile_avatar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, required this.onLoggedOut});
  final VoidCallback onLoggedOut;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileViewModelProvider);
    final logout = ref.watch(logoutViewModelProvider);
    final colors = Theme.of(context).colorScheme;
    ref.listen(profileViewModelProvider, (previous, next) {
      final feedback = next.value?.feedback;
      if (feedback != null && feedback != previous?.value?.feedback) {
        showAuthFeedback(
          context,
          AuthFeedback(feedback.message, isError: feedback.isError),
        );
      }
    });
    ref.listen(logoutViewModelProvider, (previous, next) {
      if (next.hasError && next.error != previous?.error) {
        showAuthFeedback(
          context,
          AuthFeedback.fromError(
            next.error!,
            'Unable to log out. Please try again.',
          ),
        );
      }
    });
    final busy = logout.isLoading || (profile.value?.isSaving ?? false);
    return SingleChildScrollView(
      key: const PageStorageKey('profile-scroll'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Back to home',
                onPressed: ref
                    .read(dashboardNavigationViewModelProvider.notifier)
                    .showHome,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  'My Profile',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 24),
          profile.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(60),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 42,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      error is ProfileFailure
                          ? error.message
                          : 'Unable to load your profile.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: logout.isLoading
                          ? null
                          : () => ref.invalidate(profileViewModelProvider),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            ),
            data: (state) => FinanceCard(
              child: _ProfileEditor(
                key: ValueKey(state.profile.id),
                state: state,
                isLoggingOut: logout.isLoading,
                onSave: (name, phone, bio) => ref
                    .read(profileViewModelProvider.notifier)
                    .save(fullName: name, phone: phone, bio: bio),
              ),
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: busy
                ? null
                : () async {
                    if (ref.read(profileViewModelProvider).value?.isSaving ??
                        false) {
                      return;
                    }
                    FocusScope.of(context).unfocus();
                    final success = await ref
                        .read(logoutViewModelProvider.notifier)
                        .logout();
                    if (context.mounted && success) onLoggedOut();
                  },
            style: OutlinedButton.styleFrom(
              backgroundColor: colors.surfaceContainerLow,
              foregroundColor: colors.error,
              minimumSize: const Size.fromHeight(52),
            ),
            icon: logout.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout_rounded),
            label: Text(logout.isLoading ? 'Logging out...' : 'Log out'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ProfileEditor extends StatefulWidget {
  const _ProfileEditor({
    super.key,
    required this.state,
    required this.isLoggingOut,
    required this.onSave,
  });
  final ProfileState state;
  final bool isLoggingOut;
  final Future<bool> Function(String name, String phone, String bio) onSave;
  @override
  State<_ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<_ProfileEditor> {
  late final TextEditingController _name, _phone, _bio;
  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.state.profile.fullName);
    _phone = TextEditingController(text: widget.state.profile.phone);
    _bio = TextEditingController(text: widget.state.profile.bio);
  }

  @override
  void didUpdateWidget(covariant _ProfileEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.profile != widget.state.profile) {
      _name.text = widget.state.profile.fullName;
      _phone.text = widget.state.profile.phone;
      _bio.text = widget.state.profile.bio;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.state.profile;
    final busy = widget.state.isSaving || widget.isLoggingOut;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: ProfileAvatar(profile: profile, size: 88)),
        const SizedBox(height: 16),
        Text(
          profile.displayName,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          profile.email,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 28),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Personal details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _name,
                  enabled: !busy,
                  maxLength: 80,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  key: ValueKey('email-${profile.email}'),
                  initialValue: profile.email,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    suffixIcon: Icon(Icons.lock_outline_rounded, size: 18),
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _phone,
                  enabled: !busy,
                  maxLength: 30,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  decoration: const InputDecoration(
                    labelText: 'Contact phone (optional)',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _bio,
                  enabled: !busy,
                  maxLines: 3,
                  maxLength: 300,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Bio (optional)',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () {
                          FocusScope.of(context).unfocus();
                          widget.onSave(_name.text, _phone.text, _bio.text);
                        },
                  child: widget.state.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save profile'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
