import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'loading_state_provider.g.dart';

@riverpod
class LoadingState extends _$LoadingState {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  void show([String? message]) {
    state = const AsyncLoading();
  }

  void hide() {
    state = const AsyncData(null);
  }

  void error(Object error, [StackTrace? stackTrace]) {
    state = AsyncError(error, stackTrace ?? StackTrace.current);
  }
}
