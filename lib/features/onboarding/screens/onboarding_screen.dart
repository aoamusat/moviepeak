import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/user_profile.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final Set<String> _selectedGenres = {};
  final Set<String> _selectedLanguages = {};
  final Set<String> _selectedMoods = {};
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          children: [
            Text(
              'Tune MoviePeak to your vibe',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Pick genres, languages, and moods for smarter discovery.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 24),
            _PreferenceGroup(
              title: 'Genres',
              items: AppConstants.genres,
              selected: _selectedGenres,
              onToggle: _toggleGenre,
            ),
            const SizedBox(height: 18),
            _PreferenceGroup(
              title: 'Languages',
              items: AppConstants.languages,
              selected: _selectedLanguages,
              onToggle: _toggleLanguage,
            ),
            const SizedBox(height: 18),
            _PreferenceGroup(
              title: 'Moods',
              items: AppConstants.moods,
              selected: _selectedMoods,
              onToggle: _toggleMood,
            ),
            const SizedBox(height: 26),
            PrimaryButton(
              label: 'Save Preferences',
              loading: _saving,
              onPressed: _saving ? null : _save,
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _saving
                  ? null
                  : () async {
                      await ref
                          .read(authControllerProvider.notifier)
                          .setOnboardingSeen(true);
                    },
              child: const Text('Skip for now'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleGenre(String value) => _toggle(value, _selectedGenres);
  void _toggleLanguage(String value) => _toggle(value, _selectedLanguages);
  void _toggleMood(String value) => _toggle(value, _selectedMoods);

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
    setState(() {
      _saving = true;
    });

    try {
      final updatedUser = await ref.read(userRepositoryProvider).updateMe(
            preferences: UserPreferences(
              genres: _selectedGenres.toList(growable: false),
              languages: _selectedLanguages.toList(growable: false),
              moods: _selectedMoods.toList(growable: false),
            ),
          );

      await ref.read(authControllerProvider.notifier).updateUser(updatedUser);
      await ref.read(authControllerProvider.notifier).setOnboardingSeen(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
      setState(() {
        _saving = false;
      });
    }
  }
}

class _PreferenceGroup extends StatelessWidget {
  const _PreferenceGroup({
    required this.title,
    required this.items,
    required this.selected,
    required this.onToggle,
  });

  final String title;
  final List<String> items;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in items)
              FilterChip(
                selected: selected.contains(item),
                label: Text(item),
                onSelected: (_) => onToggle(item),
              ),
          ],
        ),
      ],
    );
  }
}
