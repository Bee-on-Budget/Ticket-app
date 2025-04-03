import 'package:flutter/material.dart';
import 'package:ticket_app/src/modules/models/app_file.dart';

import '../service/file_repository.dart';

class FileListView extends StatefulWidget {
  const FileListView({
    super.key,
    required this.maxFiles,
    required this.selectedFiles,
  });

  final int maxFiles;
  final List<AppFile> selectedFiles;

  @override
  State<FileListView> createState() => _FileListViewState();
}

class _FileListViewState extends State<FileListView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Row(
          spacing: 10,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: const Text('Attach Files'),
              onPressed: () {
                pickFiles(
                  widget.maxFiles,
                  context,
                  widget.selectedFiles,
                  setState,
                );
              },
            ),
            Text(
              '${widget.selectedFiles.length}/${widget.maxFiles} files',
              style: TextStyle(
                color: widget.selectedFiles.length >= widget.maxFiles
                    ? theme.colorScheme.error
                    : theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
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
