import 'package:flutter/material.dart';
import '../theme/luster_colors.dart';
import '../theme/luster_typography.dart';

class LusterGalleryCard extends StatelessWidget {
  final String title;
  final String eventDate;
  final String videoCount;
  final String slug;
  final VoidCallback onTap;
  final VoidCallback? onQrTap;

  const LusterGalleryCard({
    super.key,
    required this.title,
    required this.eventDate,
    required this.videoCount,
    required this.slug,
    required this.onTap,
    this.onQrTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LusterColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LusterColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: LusterColors.header,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: LusterColors.primaryBlue.withOpacity(0.3)),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: LusterColors.primaryBlue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: LusterTypography.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$eventDate • $videoCount videos',
                      style: LusterTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              if (onQrTap != null)
                IconButton(
                  icon: const Icon(Icons.qr_code_2_rounded, color: LusterColors.primaryBlue),
                  onPressed: onQrTap,
                  tooltip: 'Event Gallery QR',
                ),
              const Icon(Icons.arrow_forward_ios_rounded, color: LusterColors.textMuted, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
