import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../providers/subscription_action_provider.dart';

class SubscriptionStatusScreen extends ConsumerWidget {
  const SubscriptionStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(subscriptionStatusProvider);
    final actionLoading = ref.watch(subscriptionActionLoadingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Subscription Status')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          statusAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => EmptyState(
              title: 'Unable to load subscription',
              subtitle: error.toString(),
            ),
            data: (status) {
              if (status == null) {
                return const EmptyState(
                  title: 'No active subscription',
                  subtitle: 'Start one to unlock playback.',
                );
              }

              final formatter = DateFormat('EEE, MMM d, y');
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.plan?.name ?? 'Plan',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status: ${status.status}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: AppColors.yellow),
                    ),
                    const SizedBox(height: 6),
                    if (status.currentPeriodEnd != null)
                      Text(
                        'Access until: ${formatter.format(status.currentPeriodEnd!.toLocal())}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.muted),
                      ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed:
                          actionLoading ? null : () => _cancel(context, ref),
                      icon: actionLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cancel_outlined),
                      label: const Text('Cancel Subscription'),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'If canceled, access continues until current period end.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    ref.read(subscriptionActionLoadingProvider.notifier).state = true;
    try {
      await ref.read(subscriptionsRepositoryProvider).cancel();
      ref.invalidate(subscriptionStatusProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subscription canceled.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      ref.read(subscriptionActionLoadingProvider.notifier).state = false;
    }
  }
}
