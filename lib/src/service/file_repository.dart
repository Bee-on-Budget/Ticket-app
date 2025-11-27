import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:web/web.dart' as web;

import '../modules/models/app_file.dart';
import '../modules/models/ticket_file.dart';
import 'functions.dart';

const _allowedExtensions = ['png', 'jpg', 'jpeg', 'pdf'];
const _dialogTitle = 'Select File';
const _maxFileSizeMB = 5;
const _maxFileSizeBytes = _maxFileSizeMB * 1024 * 1024;

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
            (file) => file.size > _maxFileSizeBytes,
          )
          .toList();

      if (overSizedFiles.isNotEmpty) {
        showErrorSnackBar(
          context,
          "${overSizedFiles.length} file(s) exceed "
          "${_maxFileSizeBytes ~/ 1024 ~/ 1024}MB limits",
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

Future<void> dragDropFiles(
  int maxFiles,
  BuildContext context,
  List<AppFile> selectedFiles,
  List<DropzoneFileInterface>? files,
  DropzoneViewController controller,
  void Function(void Function()) setState,
) async {
  if (files == null || files.isEmpty) {
    if (context.mounted) {
      showErrorSnackBar(context, "No files to add");
    }
    return;
  }

  final int remainingSlots = maxFiles - selectedFiles.length;

  if (remainingSlots <= 0) {
    if (context.mounted) {
      showErrorSnackBar(
          context, "You already added the maximum of $maxFiles files.");
    }
    return;
  }

  if (files.length > remainingSlots) {
    if (context.mounted) {
      showErrorSnackBar(
        context,
        "You can only add $remainingSlots more file(s).",
      );
    }
    return;
  }

  try {
    // ---- Validate file extensions ----
    final List<String> extensions =
        files.map((file) => file.name.split('.').last.toLowerCase()).toList();

    final invalidExtensions = extensions.where(
      (ext) => !_allowedExtensions.contains(ext),
    );

    if (invalidExtensions.isNotEmpty) {
      if (context.mounted) {
        showErrorSnackBar(
          context,
          "${invalidExtensions.length} file(s) have an unsupported type.",
        );
      }
      return;
    }

    // ---- Validate file sizes ----
    final overSizedFiles =
        files.where((file) => file.size > _maxFileSizeBytes).toList();

    if (overSizedFiles.isNotEmpty) {
      if (context.mounted) {
        showErrorSnackBar(
          context,
          "${overSizedFiles.length} file(s) exceed "
          "${_maxFileSizeBytes ~/ 1024 ~/ 1024}MB limit",
        );
      }
      return;
    }

    // ---- Read all file bytes in parallel ----
    final List<Uint8List> bytesList = await Future.wait(
      files.map((file) => controller.getFileData(file)),
    );

    // ---- Convert to AppFile objects ----
    final List<AppFile> webFiles = [
      for (int i = 0; i < files.length; i++)
        WebFile(
          name: files[i].name,
          bytes: bytesList[i],
          size: files[i].size,
        ),
    ];

    // ---- Update state ----
    setState(() {
      selectedFiles.addAll(webFiles);
    });
  } catch (e) {
    if (context.mounted) {
      showErrorSnackBar(context, "Error selecting files: ${e.toString()}");
    }
  }
}
