class ImageConfig {
  static const Duration cacheDuration = Duration(days: 7);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const Duration timeoutDuration = Duration(seconds: 10);
}
