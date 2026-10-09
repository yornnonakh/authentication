import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/view_models/auth_feedback.dart';
import '../../../auth/presentation/view_models/logout_view_model.dart';
import '../../../auth/presentation/widgets/auth_feedback_snackbar.dart';
import '../../../home/presentation/theme/dashboard_colors.dart';
import '../../../home/presentation/view_models/dashboard_navigation_view_model.dart';
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
    final feedbackMargin = EdgeInsets.fromLTRB(
      20,
      0,
      20,
      100 + MediaQuery.paddingOf(context).bottom,
    );
    ref.listen(profileViewModelProvider, (previous, next) {
      final feedback = next.value?.feedback;
      if (feedback != null && feedback != previous?.value?.feedback) {
        showAuthFeedback(
          context,
          AuthFeedback(feedback.message, isError: feedback.isError),
          margin: feedbackMargin,
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
          margin: feedbackMargin,
        );
      }
    });
    final busy = logout.isLoading || (profile.value?.isSaving ?? false);
    return SingleChildScrollView(
      key: const PageStorageKey('profile-scroll'),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        108 + MediaQuery.paddingOf(context).bottom,
      ),
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
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: DashboardColors.ink,
                ),
              ),
              const Expanded(
                child: Text(
                  'My Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: DashboardColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 24),
          profile.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: CircularProgressIndicator(color: DashboardColors.ink),
              ),
            ),
            error: (error, stackTrace) => Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 42,
                    color: DashboardColors.muted,
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
            data: (state) => _ProfileEditor(
              key: ValueKey(state.profile.id),
              state: state,
              isLoggingOut: logout.isLoading,
              onSave: (name, phone, bio) => ref
                  .read(profileViewModelProvider.notifier)
                  .save(fullName: name, phone: phone, bio: bio),
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
              foregroundColor: const Color(0xFFBE5366),
              side: const BorderSide(color: Color(0xFFE9CCD2)),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: logout.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout_rounded, size: 20),
            label: Text(logout.isLoading ? 'Logging out...' : 'Log out'),
          ),
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
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _bio;

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
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: DashboardColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          profile.email,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: DashboardColors.muted),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Personal details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: DashboardColors.ink,
                ),
              ),
              const SizedBox(height: 22),
              _field(
                label: 'Full name',
                controller: _name,
                enabled: !busy,
                autofillHints: const [AutofillHints.name],
                maxLength: 80,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 18),
              TextFormField(
                key: ValueKey('email-${profile.email}'),
                initialValue: profile.email,
                readOnly: true,
                decoration: _decoration('Email address').copyWith(
                  suffixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    size: 18,
                    color: DashboardColors.muted,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: DashboardColors.muted,
                ),
              ),
              const SizedBox(height: 18),
              _field(
                label: 'Contact phone (optional)',
                controller: _phone,
                enabled: !busy,
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumber],
                maxLength: 30,
              ),
              const SizedBox(height: 18),
              _field(
                label: 'Bio (optional)',
                controller: _bio,
                enabled: !busy,
                maxLines: 3,
                maxLength: 300,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: busy
                    ? null
                    : () {
                        FocusScope.of(context).unfocus();
                        widget.onSave(_name.text, _phone.text, _bio.text);
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: DashboardColors.ink,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: widget.state.isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Save profile'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: DashboardColors.muted, fontSize: 13),
    floatingLabelStyle: const TextStyle(color: DashboardColors.ink),
    filled: true,
    fillColor: const Color(0xFFFAFAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE9EAF0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE9EAF0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: DashboardColors.ink),
    ),
    counterText: '',
  );

  Widget _field({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
    Iterable<String>? autofillHints,
    int maxLines = 1,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) => TextFormField(
    controller: controller,
    enabled: enabled,
    keyboardType: keyboardType,
    autofillHints: autofillHints,
    maxLines: maxLines,
    maxLength: maxLength,
    textCapitalization: textCapitalization,
    style: const TextStyle(fontSize: 14, color: DashboardColors.ink),
    decoration: _decoration(label),
  );
}
