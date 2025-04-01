import 'package:flutter/material.dart';

import '../modules/models/ticket_file.dart';
import '../modules/screens/tickets/file_messaging_page.dart';
import '../service/data_service.dart';
import '../service/file_repository.dart';

class AttachmentCard extends StatelessWidget {
  const AttachmentCard({
    super.key,
    required this.file,
    required this.ticketId,
  });

  final TicketFile file;
  final String ticketId;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[500]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        leading: Hero(
          tag: 'file-icon-${file.refId}',
          child: Icon(
            _getFileIcon(file.fileName),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Hero(
          tag: 'file-name-${file.refId}',
          child: Material(
            type: MaterialType.transparency,
            child: Text(
              file.fileName,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Hero(
            tag: 'file-id-${file.refId}',
            child: Material(
              type: MaterialType.transparency,
              child: Text(
                'Attachment Id: ${file.refId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ),
        trailing: SizedBox(
          width: 60,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (file.isThereMsgNotRead)
                Badge(
                  smallSize: 8,
                  backgroundColor: Theme.of(context).colorScheme.error,
                )
              else
                const Spacer(),
              IconButton(
                icon: const Icon(Icons.download),
                color: Theme.of(context).colorScheme.primary,
                onPressed: () => handleDownload(context, file),
              ),
            ],
          ),
        ),
        onTap: () => _navigateToFileMessaging(context, ticketId, file),
      ),
    );
  }
  Future<void> _navigateToFileMessaging(
      BuildContext context,
      String ticketId,
      TicketFile file,
      ) async {
    if (!file.isThereMsgNotRead) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No new messages for ${file.fileName}',
          ),
        ),
      );
      return;
    }

    await DataService.changeFileUnreadMessage(ticketId, file.fileId);

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FileMessagingPage(
            ticketId: ticketId,
            file: file,
          ),
        ),
      );
    }
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }
}