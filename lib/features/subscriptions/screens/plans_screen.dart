import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import 'subscription_status_screen.dart';
import '../providers/subscription_action_provider.dart';

class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(plansProvider);
    final loading = ref.watch(subscriptionActionLoadingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Plan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          Text(
            'Mock provider enabled. Built to swap in Paystack/Flutterwave later.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          plansAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => EmptyState(
              title: 'Failed to load plans',
              subtitle: error.toString(),
            ),
            data: (plans) {
              if (plans.isEmpty) {
                return const EmptyState(
                  title: 'No plans available',
                  subtitle: 'Please check again later.',
                );
              }

              return Column(
                children: [
                  for (final plan in plans)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'NGN ${plan.priceNgn} / ${plan.billingPeriod.toLowerCase()}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: AppColors.yellow),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${plan.maxQuality}p • ${plan.screens} screen(s)',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.muted),
                          ),
                          const SizedBox(height: 12),
                          PrimaryButton(
                            label: 'Start Subscription',
                            loading: loading,
                            onPressed: loading
                                ? null
                                : () =>
                                    _startSubscription(context, ref, plan.id),
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

  Future<void> _startSubscription(
    BuildContext context,
    WidgetRef ref,
    String planId,
  ) async {
    ref.read(subscriptionActionLoadingProvider.notifier).state = true;
    try {
      await ref.read(subscriptionsRepositoryProvider).start(planId);
      ref.invalidate(subscriptionStatusProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subscription started successfully.')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SubscriptionStatusScreen()),
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
