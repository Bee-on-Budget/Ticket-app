enum PaymentMethods {
  payPal,
  applePay,
  transfer,
  cash;

  static PaymentMethods? fromString(String value) {
    switch (value) {
      case 'payPal':
        return PaymentMethods.payPal;
      case 'applePay':
        return PaymentMethods.applePay;
      case 'transfer':
        return PaymentMethods.transfer;
      case 'cash':
        return PaymentMethods.cash;
      default:
        return null;
    }
  }

  @override
  String toString() {
    final String method = toString().split('.').last;
    return "${method[0].toUpperCase()}${method.substring(1)}";
  }

}
