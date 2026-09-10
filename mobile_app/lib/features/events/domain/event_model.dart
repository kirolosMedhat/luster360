class EventModel {
  final String id;
  final String name;
  final String eventDate;
  final String? startTime;
  final String? endTime;
  final String timezone;
  final String? venue;
  final String clientName;
  final String? clientContact;
  final String? clientEmail;
  final String status; // 'DRAFT', 'ACTIVE', 'PAUSED', 'COMPLETED'
  final DateTime? startedAt;
  final DateTime? endedAt;

  // Branding
  final String? eventLogoUrl;
  final String? coverImageUrl;
  final String brandColor;
  final String brandSecondaryColor;

  // Gallery
  final String gallerySlug;
  final String galleryVisibility;
  final DateTime? galleryExpiration;
  final bool downloadEnabled;
  final bool sharingEnabled;
  final bool passwordProtected;

  // Google Drive Mappings
  final String? driveRootFolderId;
  final String? driveVideosFolderId;
  final String? driveThumbnailsFolderId;
  final String? driveBrandingFolderId;

  // Statistics
  final int videoCount;
  final int uploadedCount;
  final int pendingCount;
  final int failedCount;

  const EventModel({
    required this.id,
    required this.name,
    required this.eventDate,
    this.startTime,
    this.endTime,
    this.timezone = 'Africa/Cairo',
    this.venue,
    required this.clientName,
    this.clientContact,
    this.clientEmail,
    this.status = 'DRAFT',
    this.startedAt,
    this.endedAt,
    this.eventLogoUrl,
    this.coverImageUrl,
    this.brandColor = '#86CFFF',
    this.brandSecondaryColor = '#18283F',
    required this.gallerySlug,
    this.galleryVisibility = 'PUBLIC',
    this.galleryExpiration,
    this.downloadEnabled = true,
    this.sharingEnabled = true,
    this.passwordProtected = false,
    this.driveRootFolderId,
    this.driveVideosFolderId,
    this.driveThumbnailsFolderId,
    this.driveBrandingFolderId,
    this.videoCount = 0,
    this.uploadedCount = 0,
    this.pendingCount = 0,
    this.failedCount = 0,
  });

  bool get isActive => status == 'ACTIVE';

  EventModel copyWith({
    String? status,
    DateTime? startedAt,
    DateTime? endedAt,
    int? videoCount,
    int? uploadedCount,
    int? pendingCount,
    int? failedCount,
  }) {
    return EventModel(
      id: id,
      name: name,
      eventDate: eventDate,
      startTime: startTime,
      endTime: endTime,
      timezone: timezone,
      venue: venue,
      clientName: clientName,
      clientContact: clientContact,
      clientEmail: clientEmail,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      eventLogoUrl: eventLogoUrl,
      coverImageUrl: coverImageUrl,
      brandColor: brandColor,
      brandSecondaryColor: brandSecondaryColor,
      gallerySlug: gallerySlug,
      galleryVisibility: galleryVisibility,
      galleryExpiration: galleryExpiration,
      downloadEnabled: downloadEnabled,
      sharingEnabled: sharingEnabled,
      passwordProtected: passwordProtected,
      driveRootFolderId: driveRootFolderId,
      driveVideosFolderId: driveVideosFolderId,
      driveThumbnailsFolderId: driveThumbnailsFolderId,
      driveBrandingFolderId: driveBrandingFolderId,
      videoCount: videoCount ?? this.videoCount,
      uploadedCount: uploadedCount ?? this.uploadedCount,
      pendingCount: pendingCount ?? this.pendingCount,
      failedCount: failedCount ?? this.failedCount,
    );
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      name: json['name'] as String,
      eventDate: json['event_date'] ?? json['eventDate'] ?? '',
      startTime: json['start_time'] ?? json['startTime'],
      endTime: json['end_time'] ?? json['endTime'],
      timezone: json['timezone'] ?? 'Africa/Cairo',
      venue: json['venue'],
      clientName: json['client_name'] ?? json['clientName'] ?? '',
      clientContact: json['client_contact'] ?? json['clientContact'],
      clientEmail: json['client_email'] ?? json['clientEmail'],
      status: json['status'] ?? 'DRAFT',
      startedAt: json['started_at'] != null ? DateTime.tryParse(json['started_at']) : null,
      endedAt: json['ended_at'] != null ? DateTime.tryParse(json['ended_at']) : null,
      eventLogoUrl: json['event_logo_url'],
      coverImageUrl: json['cover_image_url'],
      brandColor: json['brand_primary_color'] ?? '#86CFFF',
      brandSecondaryColor: json['brand_secondary_color'] ?? '#18283F',
      gallerySlug: json['gallery_slug'] ?? json['gallerySlug'] ?? '',
      galleryVisibility: json['gallery_visibility'] ?? 'PUBLIC',
      galleryExpiration: json['gallery_expiration_at'] != null ? DateTime.tryParse(json['gallery_expiration_at']) : null,
      downloadEnabled: json['is_download_enabled'] ?? true,
      sharingEnabled: json['is_sharing_enabled'] ?? true,
      passwordProtected: json['gallery_visibility'] == 'PASSWORD_PROTECTED',
      driveRootFolderId: json['drive_root_folder_id'],
      driveVideosFolderId: json['drive_videos_folder_id'],
      driveThumbnailsFolderId: json['drive_thumbnails_folder_id'],
      driveBrandingFolderId: json['drive_branding_folder_id'],
      videoCount: json['videoStats']?['total'] ?? json['videoCount'] ?? 0,
      uploadedCount: json['videoStats']?['uploaded'] ?? json['uploadedCount'] ?? 0,
      pendingCount: json['videoStats']?['pending'] ?? json['pendingCount'] ?? 0,
      failedCount: json['videoStats']?['failed'] ?? json['failedCount'] ?? 0,
    );
  }
}
