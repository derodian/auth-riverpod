import 'package:auth_riverpod/src/on_boarding/data/onboarding_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_controller.g.dart';

@Riverpod(keepAlive: true)
class OnboardingController extends _$OnboardingController {
  @override
  bool build() {
    // Get synchronously from repository
    final repository = ref.watch(onboardingRepositoryProvider).valueOrNull;
    return repository?.isOnboardingComplete() ?? false;
  }

  Future<void> completeOnboarding() async {
    final repository = await ref.read(onboardingRepositoryProvider.future);
    await repository.setOnboardingComplete();
    state = true;
  }
}
