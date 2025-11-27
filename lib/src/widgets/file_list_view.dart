import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:ticket_app/src/modules/models/app_file.dart';
import 'package:ticket_app/src/service/functions.dart';

import '../service/file_repository.dart';

class FileListView extends StatefulWidget {
  const FileListView({
    super.key,
    required this.maxFiles,
    required this.selectedFiles,
    required this.isError,
  });

  final int maxFiles;
  final List<AppFile> selectedFiles;
  final bool isError;

  @override
  State<FileListView> createState() => _FileListViewState();
}

class _FileListViewState extends State<FileListView> {
  late DropzoneViewController _dropzoneViewController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        _buildDottedBorder(
          Stack(
            children: [
              DropzoneView(
                onCreated: (controller) {
                  _dropzoneViewController = controller;
                },
                onError: (error) {
                  showErrorSnackBar(context, "Something went wrong");
                },
                onDropFiles: (files) async {
                  await dragDropFiles(
                    widget.maxFiles,
                    context,
                    widget.selectedFiles,
                    files,
                    _dropzoneViewController,
                    setState,
                  );
                },
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.cloud_upload,
                        size: 50,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        await pickFiles(
                          widget.maxFiles,
                          context,
                          widget.selectedFiles,
                          setState,
                        );
                      },
                    ),
                    Text(
                      "Pick or drop files here",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          theme,
          widget.isError,
        ),
        if (widget.isError)
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              top: 4,
            ),
            child: Text(
              "Attachment are required",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            '${widget.selectedFiles.length}/${widget.maxFiles} files',
            style: TextStyle(
              color: widget.selectedFiles.length >= widget.maxFiles
                  ? theme.colorScheme.error
                  : theme.textTheme.bodySmall?.color,
            ),
          ),
        ),
        if (widget.selectedFiles.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Attached Files:'),
              const SizedBox(height: 8),
              ...widget.selectedFiles.map(
                (file) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.insert_drive_file, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(file.name),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => removeFile(
                          widget.selectedFiles,
                          file,
                          setState,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

Widget _buildDottedBorder(Widget child, ThemeData theme, bool isError) => ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        color: Color(0xFF3D4B3F),
        padding: const EdgeInsets.all(12),
        height: 200,
        child: DottedBorder(
          options: RoundedRectDottedBorderOptions(
            dashPattern: [10, 5],
            strokeWidth: 2,
            radius: Radius.circular(12),
            color: isError ? theme.colorScheme.error :Colors.white,
            padding: EdgeInsets.all(12),
          ),
          child: child,
        ),
      ),
    );
