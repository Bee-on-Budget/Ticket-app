// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'dart:io';
// import 'dart:html' as html;
//
// import '../../modules/models/ticket_file.dart';
// import '../../modules/screens/tickets/file_messaging_page.dart';
// import '../../service/data_service.dart';
//
// class AttachmentCard extends StatelessWidget {
//   const AttachmentCard({super.key, required this.file, required this.ticketId});
//
//   final TicketFile file;
//   final String ticketId;
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 8),
//       shape: RoundedRectangleBorder(
//         side: BorderSide(
//           color: Colors.grey[500]!,
//         ),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(8),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         leading: Icon(
//           Icons.insert_drive_file,
//           color: Theme.of(context).colorScheme.primary,
//         ),
//         title: Text(
//           file.fileName,
//           overflow: TextOverflow.ellipsis,
//           style: Theme.of(context).textTheme.titleSmall,
//         ),
//         subtitle: Padding(
//           padding: const EdgeInsets.only(top: 4),
//           child: Text(
//             'Attachment Id: ${file.refId}',
//             style: Theme.of(context).textTheme.bodySmall,
//           ),
//         ),
//         trailing: SizedBox(
//           width: 60,
//           child: Row(
//             spacing: 8,
//             mainAxisSize: MainAxisSize.max,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               if (file.isThereMsgNotRead)
//                 Badge(
//                   smallSize: 8,
//                   backgroundColor: Theme.of(context).colorScheme.error,
//                 )
//               else
//                 const Spacer(),
//               IconButton(
//                 icon: const Icon(Icons.download),
//                 color: Theme.of(context).colorScheme.primary,
//                 onPressed: () => _handleDownload(context, file),
//               ),
//             ],
//           ),
//         ),
//         onTap: () => _navigateToFileMessaging(context, ticketId, file),
//       ),
//     );
//   }
//
//   Future<void> _handleDownload(BuildContext context, TicketFile file) async {
//     try {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Preparing download...')),
//       );
//
//       final ref = FirebaseStorage.instance.refFromURL(file.url);
//       final downloadUrl = await ref.getDownloadURL();
//
//       if (kIsWeb) {
//         // final anchor = html.AnchorElement(href: downloadUrl)
//         html.AnchorElement(href: downloadUrl)
//           ..setAttribute('download', file.fileName)
//           ..click();
//       } else if (Platform.isIOS) {
//         if (await canLaunchUrl(Uri.parse(downloadUrl))) {
//           await launchUrl(Uri.parse(downloadUrl),
//               mode: LaunchMode.inAppWebView);
//         } else {
//           throw 'Could not launch download URL';
//         }
//       } else {
//         final directory = Platform.isAndroid || Platform.isIOS
//             ? await getApplicationDocumentsDirectory()
//             : await getDownloadsDirectory();
//
//         if (directory != null) {
//           final filePath = '${directory.path}/${file.fileName}';
//           // final taskId = await FlutterDownloader.enqueue(
//           await FlutterDownloader.enqueue(
//             url: downloadUrl,
//             savedDir: directory.path,
//             fileName: file.fileName,
//             showNotification: true,
//             openFileFromNotification: false,
//           );
//
//           FlutterDownloader.registerCallback((id, status, progress) async {
//             if (status == DownloadTaskStatus.complete) {
//               if (context.mounted) {
//                 showDialog(
//                   context: context,
//                   builder: (context) => AlertDialog(
//                     title: const Text('Download Complete'),
//                     content: const Text('Do you want to view the file?'),
//                     actions: [
//                       TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         child: const Text('No'),
//                       ),
//                       TextButton(
//                         onPressed: () async {
//                           Navigator.pop(context);
//                           if (await File(filePath).exists()) {
//                             await launchUrl(Uri.file(filePath));
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text('File not found.')),
//                             );
//                           }
//                         },
//                         child: const Text('Yes'),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//             }
//           });
//         }
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Download failed: ${e.toString()}')),
//         );
//       }
//     }
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
// }
