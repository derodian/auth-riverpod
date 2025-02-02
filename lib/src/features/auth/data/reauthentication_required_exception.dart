class ReauthenticationRequired implements Exception {
  final String message;
  final List<String> availableProviders;

  ReauthenticationRequired(this.message, {required this.availableProviders});

  @override
  String toString() => message;
}
