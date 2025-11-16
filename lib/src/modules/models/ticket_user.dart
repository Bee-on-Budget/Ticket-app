import 'package:cloud_firestore/cloud_firestore.dart';

// import '../../config/enums/payment_methods.dart';
import '../../config/enums/user_role.dart';

class TicketUser {
  final String userId;
  final String username;
  final UserRole role;
  final String email;
  final List<String> paymentMethods;
  final DateTime? createdAt;
  final List<String> companies;

  const TicketUser({
    required this.userId,
    required this.username,
    required this.role,
    required this.email,
    required this.paymentMethods,
    required this.createdAt,
    required this.companies,
  });

  factory TicketUser.fromJson(Map<String, dynamic> json) {
    return TicketUser(
      userId: json["uid"] ?? "Unknown uid",
      username: json["username"] ?? "Unknown Username",
      role: UserRole.fromString(json["role"] ?? "Unknown"),
      email: json["email"] ?? "Unknown",
      paymentMethods:
          (json['paymentMethods'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: (json["createdAt"] as Timestamp?)?.toDate(),
      companies:
          json["companies"] != null ? List<String>.from(json["companies"]) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullName': username,
      'role': role.toString(),
      'email': email,
      'paymentMethods': paymentMethods.map((pm) => pm.toString()).toList(),
      'createdAt': createdAt,
      'companies': companies,
    };
  }
}
