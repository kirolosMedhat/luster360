import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../capture/application/capture_controller.dart';
import '../../capture/domain/capture_state.dart';
import '../../events/application/event_controller.dart';
import '../../../core/theme/luster_colors.dart';
import '../../../core/theme/luster_typography.dart';
import '../../../core/widgets/luster_button.dart';
import '../../../core/widgets/luster_card.dart';
import '../../../core/widgets/luster_progress_indicator.dart';

class QrShareScreen extends ConsumerStatefulWidget {
  final String? videoShortCode;

  const QrShareScreen({super.key, this.videoShortCode});

  @override
  ConsumerState<QrShareScreen> createState() => _QrShareScreenState();
}

class _QrShareScreenState extends ConsumerState<QrShareScreen> {
  bool _showEventGalleryQr = false;

  @override
  Widget build(BuildContext context) {
    final captureState = ref.watch(captureProvider);
    final eventState = ref.watch(eventProvider);

    final isUploadedAndReady = captureState.workflowState == CaptureWorkflowState.readyToShare ||
        widget.videoShortCode != null;

    final shortCode = widget.videoShortCode ?? captureState.shortCode ?? '8F3K2A';
    final videoPublicUrl = 'https://events.luster-photobooth.com/v/$shortCode';
    final eventSlug = eventState.currentEvent?.gallerySlug ?? 'ahmed-mariam';
    final eventGalleryUrl = 'https://events.luster-photobooth.com/event/$eventSlug';

    final currentQrUrl = _showEventGalleryQr ? eventGalleryUrl : videoPublicUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Video'),
        actions: [
          TextButton.icon(
            icon: Icon(
              _showEventGalleryQr ? Icons.movie_outlined : Icons.collections_rounded,
              color: LusterColors.primaryBlue,
            ),
            label: Text(
              _showEventGalleryQr ? 'Show Video QR' : 'Show Event QR',
              style: const TextStyle(color: LusterColors.primaryBlue, fontWeight: FontWeight.w600),
            ),
            onPressed: () {
              setState(() {
                _showEventGalleryQr = !_showEventGalleryQr;
              });
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Event Branding Header
              Text(
                'LUSTER 360',
                style: LusterTypography.bodySmall.copyWith(
                  color: LusterColors.primaryBlue,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                eventState.currentEvent?.name ?? 'Ahmed & Mariam Wedding',
                style: LusterTypography.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Conditional Status-Aware QR Display
              if (!isUploadedAndReady && captureState.workflowState == CaptureWorkflowState.uploading) ...[
                // 1. Uploading State
                LusterCard(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.cloud_upload_rounded, color: LusterColors.primaryBlue, size: 64),
                      const SizedBox(height: 16),
                      Text('UPLOADING VIDEO', style: LusterTypography.titleLarge),
                      const SizedBox(height: 8),
                      Text('Transferring directly to cloud storage...', style: LusterTypography.bodyMedium),
                      const SizedBox(height: 24),
                      LusterProgressIndicator(
                        progress: captureState.uploadProgress,
                        label: 'Upload Progress',
                      ),
                    ],
                  ),
                ),
              ] else if (!isUploadedAndReady) ...[
                // 2. Offline / Local Only State
                LusterCard(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.save_alt_rounded, color: LusterColors.warning, size: 64),
                      const SizedBox(height: 16),
                      Text('VIDEO SAVED LOCALLY', style: LusterTypography.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        'Video is saved safely on device.\nWaiting for internet to generate public cloud link.',
                        style: LusterTypography.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // 3. Verified Ready State -> Display Genuine QR Code
                LusterCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: QrImageView(
                          data: currentQrUrl,
                          version: QrVersions.auto,
                          size: 240,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _showEventGalleryQr ? 'SCAN FOR ALL EVENT MEMORIES' : 'SCAN TO WATCH & DOWNLOAD',
                        style: LusterTypography.titleMedium.copyWith(
                          color: LusterColors.primaryBlue,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentQrUrl,
                        style: LusterTypography.bodySmall.copyWith(
                          color: LusterColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              LusterButton(
                label: 'Back to Capture',
                variant: LusterButtonVariant.secondary,
                width: 200,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
