// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import '../../widgets/form_field_outline.dart';
// import '../../widgets/submit_button.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController _controller = TextEditingController();
//   final CollectionReference _messagesCollection =
//   FirebaseFirestore.instance.collection('messages');
//
//   Future<void> _sendTest() async {
//     final message = _controller.text.trim();
//     final scaffoldMessenger = ScaffoldMessenger.of(context);
//
//     if (message.isEmpty) {
//       scaffoldMessenger.showSnackBar(
//         const SnackBar(content: Text("Message cannot be empty")),
//       );
//       return;
//     }
//
//     try {
//       // Add message to FireStore
//       await _messagesCollection.add({
//         'message': message,
//         'timestamp': FieldValue.serverTimestamp(), // FireStore-managed timestamp
//       });
//
//       _controller.clear();
//
//       scaffoldMessenger.showSnackBar(
//         const SnackBar(content: Text("Message sent successfully!")),
//       );
//     } catch (e) {
//       scaffoldMessenger.showSnackBar(
//         SnackBar(content: Text("Failed to send message: $e")),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           children: [
//             FormFieldOutline(
//               controller: _controller,
//               hintText: "Enter your message",
//               obscureText: false,
//               prefixIcon: const Icon(Icons.message),
//             ),
//             SubmitButton(
//               onPressed: () {
//                 if (_formKey.currentState!.validate()) {
//                   _sendTest();
//                 }
//               },
//               buttonText: "Submit",
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }