import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:web/web.dart' as web;

import '../modules/models/app_file.dart';
import '../modules/models/ticket_file.dart';
import 'functions.dart';

const _allowedExtensions = ['png', 'jpg', 'jpeg', 'pdf'];
const _dialogTitle = 'Select File';

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

Future<AppFile?> pickAFile(
  BuildContext context,
) async {
  AppFile? selectedFile;
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: kIsWeb,
      dialogTitle: _dialogTitle,
      lockParentWindow: true,
      allowCompression: false,
      allowedExtensions: _allowedExtensions,
    );

    if (result != null) {
      final platformFile = result.files.first;
        if (kIsWeb || platformFile.path == null) {
          selectedFile = WebFile(
            name: platformFile.name,
            bytes: platformFile.bytes!,
            size: platformFile.size,
          );
        } else {
          selectedFile = LocalFile(
            name: platformFile.name,
            file: File(platformFile.path!),
            size: platformFile.size,
          );
        }
      return selectedFile;
    }
  } catch (e) {
    if (context.mounted) {
      showErrorSnackBar(context, "Error selecting files: ${e.toString()}");
    }
  }
  return null;
}

Future<void> pickFiles(
  int maxFiles,
  BuildContext context,
  List<AppFile> selectedFiles,
  void Function(void Function()) setState,
) async {
  const maxFileSizeMB = 5;
  const maxFileSizeBytes = maxFileSizeMB * 1024 * 1024;
  try {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      withData: kIsWeb,
      dialogTitle: _dialogTitle,
      lockParentWindow: true,
      allowCompression: false,
      allowedExtensions: _allowedExtensions,
    );

    if (result != null && context.mounted) {
      final newFileCount = result.files.length;
      final totalFiles = selectedFiles.length + newFileCount;

      if (totalFiles > maxFiles) {
        showErrorSnackBar(context, "Maximum $maxFiles files allowed");
        return;
      }

      final overSizedFiles = result.files
          .where(
            (file) => file.size > maxFileSizeBytes,
          )
          .toList();

      if (overSizedFiles.isNotEmpty) {
        showErrorSnackBar(
          context,
          "${overSizedFiles.length} file(s) exceed "
          "${maxFileSizeBytes ~/ 1024 ~/ 1024}MB limits",
        );
        return;
      }

      setState(() {
        selectedFiles.addAll(
          result.files.map((PlatformFile platformFile) {
            if (kIsWeb || platformFile.path == null) {
              return WebFile(
                name: platformFile.name,
                bytes: platformFile.bytes!,
                size: platformFile.size,
              );
            }
            return LocalFile(
              name: platformFile.name,
              file: File(platformFile.path!),
              size: platformFile.size,
            );
          }).toList(),
        );
      });
    }
  } catch (e) {
    if (context.mounted) {
      showErrorSnackBar(context, "Error selecting files: ${e.toString()}");
    }
  }
}

void removeFile(
  List<AppFile> selectedFiles,
  AppFile file,
  void Function(void Function()) setState,
) {
  setState(() {
    selectedFiles.remove(file);
  });
}

String _getDownloadUrl(String originalUrl) {
  final uri = Uri.parse(originalUrl);
  if (!uri.queryParameters.containsKey('alt')) {
    return '${originalUrl.replaceFirst(uri.path, Uri.encodeFull(uri.path))}?alt=media';
  }
  return originalUrl;
}
