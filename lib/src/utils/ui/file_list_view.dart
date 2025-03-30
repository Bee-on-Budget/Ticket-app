import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:html' as html;

import '../../modules/models/ticket.dart';
import '../../modules/models/ticket_file.dart';
import '../../modules/screens/tickets/file_messaging_page.dart';
import '../../service/data_service.dart';

class FileListView extends StatelessWidget {
  const FileListView({super.key, required this.ticket});

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    final List<TicketFile> files = ticket.files;
    if (files.isEmpty) {
      return const Center(child: Text('No attachments'));
    }
    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _handleDownload(context, file),
            ),
            title: Text(
              file.fileName,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text('Attachment Id: ${file.refId}'),
            trailing: file.isThereMsgNotRead
                ? Icon(
              Icons.notification_important_outlined,
              color: Theme.of(context).colorScheme.error,
            )
                : null,
            onTap: () => _navigateToFileMessaging(context, ticket, file),
          ),
        );
      },
    );
  }

  Future<void> _handleDownload(BuildContext context, TicketFile file) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preparing download...')),
      );

      final ref = FirebaseStorage.instance.refFromURL(file.url);
      final downloadUrl = await ref.getDownloadURL();

      if (kIsWeb) {
        final anchor = html.AnchorElement(href: downloadUrl)
          ..setAttribute('download', file.fileName)
          ..click();
      } else if (Platform.isIOS) {
        if (await canLaunchUrl(Uri.parse(downloadUrl))) {
          await launchUrl(Uri.parse(downloadUrl), mode: LaunchMode.inAppWebView);
        } else {
          throw 'Could not launch download URL';
        }
      } else {
        final directory = Platform.isAndroid || Platform.isIOS
            ? await getApplicationDocumentsDirectory()
            : await getDownloadsDirectory();

        if (directory != null) {
          final filePath = '${directory.path}/${file.fileName}';
          final taskId = await FlutterDownloader.enqueue(
            url: downloadUrl,
            savedDir: directory.path,
            fileName: file.fileName,
            showNotification: true,
            openFileFromNotification: false,
          );

          FlutterDownloader.registerCallback((id, status, progress) async {
            if (status == DownloadTaskStatus.complete) {
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Download Complete'),
                    content: const Text('Do you want to view the file?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          if (await File(filePath).exists()) {
                            await launchUrl(Uri.file(filePath));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('File not found.')),
                            );
                          }
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
                );
              }
            }
          });
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _navigateToFileMessaging(
      BuildContext context,
      Ticket ticket,
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

    await DataService.changeFileUnreadMessage(ticket.ticketId, file.fileId);

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FileMessagingPage(
            ticketId: ticket.ticketId,
            file: file,
          ),
        ),
      );
    }
  }
}