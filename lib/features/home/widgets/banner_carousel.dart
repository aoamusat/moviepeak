import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/marketing_banner.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({
    super.key,
    required this.banners,
    required this.onBannerTap,
  });

  final List<MarketingBanner> banners;
  final ValueChanged<MarketingBanner> onBannerTap;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);

    if (widget.banners.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (!_pageController.hasClients || widget.banners.isEmpty) {
          return;
        }

        final next = (_index + 1) % widget.banners.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Latest on MoviePeak',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            onPageChanged: (value) {
              setState(() {
                _index = value;
              });
            },
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index == widget.banners.length - 1 ? 0 : 10,
                ),
                child: _BannerCard(
                  banner: banner,
                  onTap: () => widget.onBannerTap(banner),
                ),
              );
            },
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.banners.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _index == i ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _index == i
                        ? AppColors.yellow
                        : AppColors.muted.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner, required this.onTap});

  final MarketingBanner banner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          color: AppColors.surface,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (banner.hasImage)
              Image.network(
                banner.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallbackBackground(),
              )
            else
              _fallbackBackground(),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.12),
                    Colors.black.withValues(alpha: 0.82),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.yellow.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                          color: AppColors.yellow.withValues(alpha: 0.6)),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: AppColors.yellow,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    banner.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  if (banner.subtitle != null &&
                      banner.subtitle!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      banner.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.white70),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackBackground() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E1E26),
            Color(0xFF101015),
          ],
        ),
      ),
    );
  }
}
