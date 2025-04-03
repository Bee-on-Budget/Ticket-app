import 'package:flutter/material.dart';
import 'package:ticket_app/src/service/functions.dart';

import '../config/enums/ticket_status.dart';
import '../modules/models/ticket.dart';
import '../modules/models/ticket_file.dart';
import '../modules/screens/tickets/file_messaging_page.dart';
import '../service/data_service.dart';
import '../service/file_repository.dart';

class AttachmentCard extends StatefulWidget {
  const AttachmentCard({
    super.key,
    required this.file,
    required this.ticket,
  });

  final TicketFile file;
  final Ticket ticket;

  @override
  State<AttachmentCard> createState() => _AttachmentCardState();
}

class _AttachmentCardState extends State<AttachmentCard> {
  bool _isReplacing = false;
  late final TicketStatus ticketStatus = widget.ticket.status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[500]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _isReplacing
          ? _buildReplacementSkeleton(theme)
          : ListTile(
              contentPadding: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              leading: Hero(
                tag: 'file-icon-${widget.file.refId}',
                child: Icon(
                  _getFileIcon(widget.file.fileName),
                  color: theme.colorScheme.primary,
                ),
              ),
              title: Hero(
                tag: 'file-name-${widget.file.refId}',
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    widget.file.fileName,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Hero(
                  tag: 'file-id-${widget.file.refId}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      'Attachment Id: ${widget.file.refId}',
                      style: theme.textTheme.bodySmall,
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
                    if (widget.file.isThereMsgNotRead)
                      Badge(
                        smallSize: 8,
                        backgroundColor: theme.colorScheme.error,
                      )
                    else
                      const Spacer(),
                    PopupMenuButton(itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          onTap: () => handleDownload(context, widget.file),
                          child: _menuButton(
                            Icons.download,
                            'Download',
                            theme,
                          ),
                        ),
                        PopupMenuItem(
                          enabled:
                              ticketStatus == TicketStatus.needReWork,
                          onTap: () => _handleReUpload(
                            context,
                            widget.ticket.ticketId,
                            widget.file,
                          ),
                          child: _menuButton(
                            Icons.edit,
                            'Re-upload file',
                            theme,
                          ),
                        ),
                      ];
                    }),
                  ],
                ),
              ),
              onTap: () => _navigateToFileMessaging(
                context,
                widget.ticket.ticketId,
                widget.file,
              ),
            ),
    );
  }

  Widget _buildReplacementSkeleton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Skeleton(
            width: 40,
            height: 40,
            radius: 20,
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(
                  width: double.infinity,
                  height: 16,
                  radius: 4,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 8),
                Skeleton(
                  width: 120,
                  height: 12,
                  radius: 4,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CircularProgressIndicator(
            strokeWidth: 2,
            valueColor:
                AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Future<void> _handleReUpload(
    BuildContext context,
    String ticketId,
    TicketFile oldFile,
  ) async {
    if (widget.ticket.status != TicketStatus.needReWork) {
      showErrorSnackBar(context, 'Ticket is not in need rework status');
      return;
    }

    final newFile = await pickAFile(context);
    if (newFile == null) {
      if (!context.mounted) return;
      showErrorSnackBar(context, 'No file selected');
      return;
    }

    setState(() => _isReplacing = true);

    try {
      await DataService.replaceOldFile(
        ticketId: ticketId,
        oldFile: oldFile,
        newFile: newFile,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File replaced successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, 'Failed to replace file: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isReplacing = false);
      }
    }
  }

  _menuButton(IconData icon, String text, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
        ),
        Text(text),
      ],
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

// Simple Skeleton Widget
class Skeleton extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Color color;

  const Skeleton({
    super.key,
    required this.width,
    required this.height,
    this.radius = 0,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// class AttachmentCard extends StatelessWidget {
//   const AttachmentCard({
//     super.key,
//     required this.file,
//     required this.ticket,
//   });
//
//   final TicketFile file;
//   final Ticket ticket;
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Card(
//       margin: const EdgeInsets.only(bottom: 8),
//       shape: RoundedRectangleBorder(
//         side: BorderSide(color: Colors.grey[500]!),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(8),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         leading: Hero(
//           tag: 'file-icon-${file.refId}',
//           child: Icon(
//             _getFileIcon(file.fileName),
//             color: theme.colorScheme.primary,
//           ),
//         ),
//         title: Hero(
//           tag: 'file-name-${file.refId}',
//           child: Material(
//             type: MaterialType.transparency,
//             child: Text(
//               file.fileName,
//               overflow: TextOverflow.ellipsis,
//               style: theme.textTheme.titleSmall,
//             ),
//           ),
//         ),
//         subtitle: Padding(
//           padding: const EdgeInsets.only(top: 4),
//           child: Hero(
//             tag: 'file-id-${file.refId}',
//             child: Material(
//               type: MaterialType.transparency,
//               child: Text(
//                 'Attachment Id: ${file.refId}',
//                 style: theme.textTheme.bodySmall,
//               ),
//             ),
//           ),
//         ),
//         trailing: SizedBox(
//           width: 60,
//           child: Row(
//             mainAxisSize: MainAxisSize.max,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               if (file.isThereMsgNotRead)
//                 Badge(
//                   smallSize: 8,
//                   backgroundColor: theme.colorScheme.error,
//                 )
//               else
//                 const Spacer(),
//               PopupMenuButton(itemBuilder: (context) {
//                 return [
//                   PopupMenuItem(
//                     onTap: () => handleDownload(context, file),
//                     child: _menuButton(
//                       Icons.download,
//                       'Download',
//                       theme,
//                     ),
//                   ),
//                   PopupMenuItem(
//                     enabled: ticket.status == TicketStatus.needReWork,
//                     onTap: () => _handleReUpload(context, ticket.ticketId, file),
//                     child: _menuButton(
//                       Icons.edit,
//                       'Re-upload file',
//                       theme,
//                     ),
//                   ),
//                 ];
//               }),
//             ],
//           ),
//         ),
//         onTap: () => _navigateToFileMessaging(
//           context,
//           ticket.ticketId,
//           file,
//         ),
//       ),
//     );
//   }
//
//   _handleReUpload(
//     BuildContext context,
//     String ticketId,
//     TicketFile oldFile,
//   ) async {
//     if (ticket.status != TicketStatus.needReWork) {
//       showErrorSnackBar(context, 'Ticket is not in need rework status');
//       return;
//     }
//     final newFile = await pickAFile(context);
//     if (newFile == null) {
//       if (!context.mounted) return;
//       showErrorSnackBar(context, 'No file selected');
//       return;
//     }
//     await DataService.replaceOldFile(
//       ticketId: ticketId,
//       oldFile: oldFile,
//       newFile: newFile,
//     );
//   }
//
//   _menuButton(IconData icon, String text, ThemeData theme) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       spacing: 8,
//       children: [
//         Icon(
//           icon,
//           color: theme.colorScheme.primary,
//         ),
//         Text(text),
//       ],
//     );
//   }
//
//   Future<void> _navigateToFileMessaging(
//     BuildContext context,
//     String ticketId,
//     TicketFile file,
//   ) async {
//     if (!file.isThereMsgNotRead) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'No new messages for ${file.fileName}',
//           ),
//         ),
//       );
//       return;
//     }
//
//     await DataService.changeFileUnreadMessage(ticketId, file.fileId);
//
//     if (context.mounted) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => FileMessagingPage(
//             ticketId: ticketId,
//             file: file,
//           ),
//         ),
//       );
//     }
//   }
//
//   IconData _getFileIcon(String fileName) {
//     final ext = fileName.split('.').last.toLowerCase();
//     switch (ext) {
//       case 'pdf':
//         return Icons.picture_as_pdf;
//       case 'png':
//       case 'jpg':
//       case 'jpeg':
//         return Icons.image;
//       case 'doc':
//       case 'docx':
//         return Icons.description;
//       default:
//         return Icons.insert_drive_file;
//     }
//   }
// }
