import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:web/web.dart' as web;

import '../modules/models/ticket_file.dart';

Future<void> handleDownload(BuildContext context, TicketFile file) async {
  try {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting download...')),
    );

    final downloadUrl = _getDownloadUrl(file.url);

    if (kIsWeb) {
      // Create anchor element using package:web
      final anchor = web.HTMLAnchorElement()
        ..href = downloadUrl
        ..download = file.fileName
        ..style.display = 'none';
      html.document.body?.children.add(anchor);

      // Add to DOM and trigger click
      web.document.body?.append(anchor);
      anchor.click();
      web.document.body?.removeChild(anchor);
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