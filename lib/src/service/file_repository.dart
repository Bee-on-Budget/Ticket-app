import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:html' as html;

import '../modules/models/ticket_file.dart';

Future<void> handleDownload(BuildContext context, TicketFile file) async {
  try {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting download... Hello Bob!!')),
    );

    // Construct proper download URL
    final downloadUrl = _getDownloadUrl(file.url);

    if (kIsWeb) {
      // Direct download for web
      final anchor = html.AnchorElement(href: downloadUrl)
        ..download = file.fileName
        ..style.display = 'none';
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
    } else {
      // Mobile download handling
      final directory = await getApplicationDocumentsDirectory();
      await FlutterDownloader.enqueue(
        url: downloadUrl,
        savedDir: directory.path,
        fileName: file.fileName,
        showNotification: true,
        openFileFromNotification: true,
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: ${e.toString()}')),
      );
    }
  }
}

String _getDownloadUrl(String originalUrl) {
  final uri = Uri.parse(originalUrl);
  if (!uri.queryParameters.containsKey('alt')) {
    return '${originalUrl.replaceFirst(uri.path, Uri.encodeFull(uri.path))}?alt=media';
  }
  return originalUrl;
}