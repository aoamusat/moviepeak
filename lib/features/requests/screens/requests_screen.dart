import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/requests_provider.dart';

class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topRequests = ref.watch(topRequestsProvider);
    final isSubmitting = ref.watch(requestsSubmittingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Movie Requests')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          Text(
            'Didn\'t find what you want? Request it and we\'ll track demand.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Movie title',
              prefixIcon: Icon(Icons.movie_filter_outlined),
            ),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Submit Request',
            loading: isSubmitting,
            onPressed: isSubmitting ? null : _submit,
          ),
          const SizedBox(height: 16),
          Text(
            'Top Requested',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          topRequests.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => EmptyState(
              title: 'Could not load requests',
              subtitle: error.toString(),
            ),
            data: (requests) {
              if (requests.isEmpty) {
                return const EmptyState(
                  title: 'No requests yet',
                  subtitle: 'Be the first to request a movie.',
                );
              }

              return Column(
                children: [
                  for (final request in requests)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department_outlined),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              request.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.yellow.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text('${request.count}'),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      return;
    }

    ref.read(requestsSubmittingProvider.notifier).state = true;
    try {
      await ref.read(requestsRepositoryProvider).create(title);
      if (!mounted) return;
      _titleController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movie request submitted.')),
      );
      ref.invalidate(topRequestsProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      ref.read(requestsSubmittingProvider.notifier).state = false;
    }
  }
}
