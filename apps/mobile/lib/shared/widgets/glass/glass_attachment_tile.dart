import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/glass_tokens.dart';
import 'glass_surface.dart';

enum AttachmentFileType { pdf, image, other }

/// Glass-styled file row for attachment download/open actions.
class GlassAttachmentTile extends StatelessWidget {
  const GlassAttachmentTile({
    super.key,
    required this.fileName,
    required this.onTap,
    this.fileSize,
    this.fileType = AttachmentFileType.other,
    this.trailingIcon = Icons.download_outlined,
  });

  final String fileName;
  final String? fileSize;
  final AttachmentFileType fileType;
  final IconData trailingIcon;
  final VoidCallback onTap;

  static AttachmentFileType fromMime(
    String? mimeType, {
    bool isPdf = false,
    String fileName = '',
  }) {
    if (isPdf || mimeType == 'application/pdf') return AttachmentFileType.pdf;
    if (mimeType != null && mimeType.startsWith('image/')) {
      return AttachmentFileType.image;
    }
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) return AttachmentFileType.pdf;
    if (lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp')) {
      return AttachmentFileType.image;
    }
    return AttachmentFileType.other;
  }

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassSurface(
        intensity: GlassIntensity.subtle,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [],
        padding: const EdgeInsets.all(12),
        onTap: onTap,
        child: Row(
          children: [
            _FileIcon(fileType: fileType),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: glass.textOnGlass,
                    ),
                  ),
                  if (fileSize != null && fileSize!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      fileSize!,
                      style: TextStyle(
                        fontSize: 11,
                        color: glass.textOnGlassMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(trailingIcon, color: AppTheme.primaryColor, size: 20),
          ],
        ),
      ),
    );
  }
}

class _FileIcon extends StatelessWidget {
  const _FileIcon({required this.fileType});

  final AttachmentFileType fileType;

  @override
  Widget build(BuildContext context) {
    switch (fileType) {
      case AttachmentFileType.pdf:
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: const Text(
            'PDF',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFFB91C1C),
            ),
          ),
        );
      case AttachmentFileType.image:
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: const Text(
            'IMG',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0369A1),
            ),
          ),
        );
      case AttachmentFileType.other:
        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.insert_drive_file_outlined,
            size: 18,
            color: AppTheme.secondaryColor,
          ),
        );
    }
  }
}
