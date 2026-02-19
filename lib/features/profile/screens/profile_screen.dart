import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/user_profile.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../subscriptions/screens/plans_screen.dart';
import '../../subscriptions/screens/subscription_status_screen.dart';
import '../providers/profile_edit_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  Set<String> _genres = {};
  Set<String> _languages = {};
  Set<String> _moods = {};

  String _lastUserId = '';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    _syncFromUser(user);

    final saving = ref.watch(profileSavingProvider);
    final watchHistoryAsync = ref.watch(watchHistoryProvider(1));
    final subscriptionAsync = ref.watch(subscriptionStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          _sectionCard(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.email,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Role: ${user.role}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal info',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _sectionCard(
            context,
            child: _PreferencesEditor(
              genres: _genres,
              languages: _languages,
              moods: _moods,
              onToggleGenre: (value) => _toggle(value, _genres),
              onToggleLanguage: (value) => _toggle(value, _languages),
              onToggleMood: (value) => _toggle(value, _moods),
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Save Profile',
            loading: saving,
            onPressed: saving ? null : _save,
          ),
          const SizedBox(height: 8),
          subscriptionAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (status) {
              return OutlinedButton(
                onPressed: () {
                  if (status == null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PlansScreen()),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SubscriptionStatusScreen(),
                      ),
                    );
                  }
                },
                child: Text(
                  status == null ? 'Start Subscription' : 'Manage Subscription',
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Continue Watching',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          watchHistoryAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => EmptyState(
              title: 'Could not load watch history',
              subtitle: error.toString(),
            ),
            data: (history) {
              if (history.items.isEmpty) {
                return const EmptyState(
                  title: 'No watch history yet',
                  subtitle: 'Start a movie and your progress appears here.',
                );
              }

              final formatter = DateFormat('MMM d, h:mm a');
              return Column(
                children: [
                  for (final item in history.items)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.movie?.title ?? 'Movie ${item.movieId}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Progress: ${item.positionSeconds}s / ${item.durationSeconds}s',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.muted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Updated ${formatter.format(item.updatedAt.toLocal())}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: auth.status == AuthStatus.loading
                ? null
                : () async {
                    await ref.read(authControllerProvider.notifier).logout();
                  },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(BuildContext context, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  void _syncFromUser(UserProfile user) {
    if (_lastUserId == user.id) {
      return;
    }

    _lastUserId = user.id;
    _nameController.text = user.name ?? '';
    _phoneController.text = user.phone ?? '';
    _genres = user.preferences.genres.toSet();
    _languages = user.preferences.languages.toSet();
    _moods = user.preferences.moods.toSet();
  }

  void _toggle(String value, Set<String> target) {
    setState(() {
      if (target.contains(value)) {
        target.remove(value);
      } else {
        target.add(value);
      }
    });
  }

  Future<void> _save() async {
    ref.read(profileSavingProvider.notifier).state = true;

    try {
      final updated = await ref.read(userRepositoryProvider).updateMe(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            preferences: UserPreferences(
              genres: _genres.toList(growable: false),
              languages: _languages.toList(growable: false),
              moods: _moods.toList(growable: false),
            ),
          );

      await ref.read(authControllerProvider.notifier).updateUser(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      ref.read(profileSavingProvider.notifier).state = false;
    }
  }
}

class _PreferencesEditor extends StatelessWidget {
  const _PreferencesEditor({
    required this.genres,
    required this.languages,
    required this.moods,
    required this.onToggleGenre,
    required this.onToggleLanguage,
    required this.onToggleMood,
  });

  final Set<String> genres;
  final Set<String> languages;
  final Set<String> moods;
  final ValueChanged<String> onToggleGenre;
  final ValueChanged<String> onToggleLanguage;
  final ValueChanged<String> onToggleMood;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferences',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        _chips(
          context,
          label: 'Genres',
          options: AppConstants.genres,
          selected: genres,
          onToggle: onToggleGenre,
        ),
        const SizedBox(height: 10),
        _chips(
          context,
          label: 'Languages',
          options: AppConstants.languages,
          selected: languages,
          onToggle: onToggleLanguage,
        ),
        const SizedBox(height: 10),
        _chips(
          context,
          label: 'Moods',
          options: AppConstants.moods,
          selected: moods,
          onToggle: onToggleMood,
        ),
      ],
    );
  }

  Widget _chips(
    BuildContext context, {
    required String label,
    required List<String> options,
    required Set<String> selected,
    required ValueChanged<String> onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              FilterChip(
                label: Text(option),
                selected: selected.contains(option),
                onSelected: (_) => onToggle(option),
              ),
          ],
        ),
      ],
    );
  }
}
