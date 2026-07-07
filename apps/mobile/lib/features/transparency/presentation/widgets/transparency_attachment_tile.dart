import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/widgets/glass/glass_attachment_tile.dart';
import '../../domain/entities/transparency_attachment.dart';
import '../../domain/usecases/cache_attachment.dart';

/// Download/open row for a transparency attachment.
class TransparencyAttachmentTile extends ConsumerWidget {
  const TransparencyAttachmentTile({super.key, required this.attachment});

  final TransparencyAttachment attachment;

  Future<void> _openAttachment(BuildContext context, WidgetRef ref) async {
    var launched = false;
    final result =
        await ref.read(cacheAttachmentUseCaseProvider).call(attachment);
    final uri = result.fold((_) => null, (uri) => uri);
    if (uri != null) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } on Object {
        launched = false;
      }
    }
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open ${attachment.fileName}')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassAttachmentTile(
      fileName: attachment.fileName,
      fileSize: attachment.readableSize.isNotEmpty
          ? attachment.readableSize
          : null,
      fileType: GlassAttachmentTile.fromMime(
        attachment.mimeType,
        isPdf: attachment.isPdf,
        fileName: attachment.fileName,
      ),
      onTap: () => _openAttachment(context, ref),
    );
  }
}
