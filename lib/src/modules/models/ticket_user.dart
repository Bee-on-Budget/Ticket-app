import 'package:cloud_firestore/cloud_firestore.dart';

// import '../../config/enums/payment_methods.dart';
import '../../config/enums/user_role.dart';

class TicketUser {
  final String userId;
  final String username;
  final UserRole role;
  final String identifier;
  final List<String> paymentMethods;
  final DateTime? createdAt;
  final List<String> companies;

  const TicketUser({
    required this.userId,
    required this.username,
    required this.role,
    required this.identifier,
    required this.paymentMethods,
    required this.createdAt,
    required this.companies,
  });

  factory TicketUser.fromJson(Map<String, dynamic> json) {
    return TicketUser(
      userId: json["uid"] ?? "Unknown uid",
      username: json["fullName"] ?? "Unknown Username",
      role: UserRole.fromString(json["role"] ?? "Unknown"),
      identifier: json["identifier"] ?? "Unknown",
      paymentMethods:
          (json['paymentMethods'] as List<dynamic>?)?.cast<String>() ?? [],
      // paymentMethods: json["paymentMethods"] != null
      //     ? (json["paymentMethods"] as List<dynamic>)
      //     .map((method) => PaymentMethods.fromString(method as String))
      //     .whereType<PaymentMethods>()
      //     .toList()
      //     : [],
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
      'identifier': identifier,
      'paymentMethods': paymentMethods.map((pm) => pm.toString()).toList(),
      'createdAt': createdAt,
      'companies': companies,
    };
  }
}
