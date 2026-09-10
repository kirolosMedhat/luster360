import 'package:flutter/material.dart';
import '../theme/luster_colors.dart';
import '../theme/luster_typography.dart';
import 'luster_status_badge.dart';

class LusterVideoCard extends StatelessWidget {
  final String title;
  final String duration;
  final String? shortCode;
  final String? thumbnailUrl;
  final LusterBoothStatus status;
  final VoidCallback onTap;
  final VoidCallback? onShare;

  const LusterVideoCard({
    super.key,
    required this.title,
    required this.duration,
    this.shortCode,
    this.thumbnailUrl,
    required this.status,
    required this.onTap,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LusterColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LusterColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: LusterColors.surface,
                    child: const Center(
                      child: Icon(
                        Icons.movie_filter_rounded,
                        color: LusterColors.textMuted,
                        size: 40,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: LusterStatusBadge(status: status),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        duration,
                        style: LusterTypography.bodySmall.copyWith(
                          color: LusterColors.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: LusterTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: LusterColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (shortCode != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Code: $shortCode',
                            style: LusterTypography.monoTimer.copyWith(fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onShare != null)
                    IconButton(
                      icon: const Icon(Icons.qr_code_rounded, color: LusterColors.primaryBlue),
                      onPressed: onShare,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
