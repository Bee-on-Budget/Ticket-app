// import 'dart:io';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
//
// // Modified FileViewerPage
// class FileViewerPage extends StatelessWidget {
//   final String filePath;
//   final String fileName;
//   final String fileRefId;
//   final bool isLocalFile;
//
//   const FileViewerPage({
//     super.key,
//     required this.filePath,
//     required this.fileName,
//     required this.fileRefId,
//     this.isLocalFile = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final isImage = fileName.toLowerCase().endsWith('.png') ||
//         fileName.toLowerCase().endsWith('.jpg') ||
//         fileName.toLowerCase().endsWith('.jpeg');
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(fileName),
//       ),
//       body: Center(
//         child: kIsWeb && isImage
//             ? Image.network(filePath) // Use network image directly for web
//             : isImage
//             ? Image.file(File(filePath))
//             : SfPdfViewer.file(File(filePath)),
//       ),
//     );
//   }
// }