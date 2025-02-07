import 'dart:async';

import 'package:auth_riverpod/src/features/auth/presentation/auth_controller.dart';
import 'package:auth_riverpod/src/routing/app_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'waiting_approval_screen_controller.g.dart';

// @riverpod
// class WaitingApprovalController extends _$WaitingApprovalController {
//   Timer? _refreshTimer;

//   @override
//   FutureOr<void> build() {
//     ref.onDispose(() => _refreshTimer?.cancel());
//     return null;
//   }

//   Future<void> startPeriodicRefresh() async {
//     _refreshTimer?.cancel();
//     _refreshTimer = Timer.periodic(
//       const Duration(minutes: 5),
//       (_) => checkApprovalStatus(),
//     );
//     await checkApprovalStatus();
//   }

//   Future<void> checkApprovalStatus() async {
//     state = const AsyncLoading();
//     try {
//       await ref.read(authControllerProvider.notifier).reload();
//       state = const AsyncData(null);
//     } catch (e, st) {
//       state = AsyncError(e, st);
//     }
//   }

//   Future<void> sendSupportMessage(String message) async {
//     state = const AsyncLoading();
//     try {
//       final user = ref.read(authControllerProvider).value;
//       if (user == null) throw Exception('User not found');

//       await FirebaseFirestore.instance.collection('support_messages').add({
//         'userId': user.id,
//         'userEmail': user.email,
//         'message': message,
//         'timestamp': FieldValue.serverTimestamp(),
//         'status': 'pending',
//         'type': 'approval_request',
//       });

//       state = const AsyncData(null);
//     } catch (e, st) {
//       state = AsyncError(e, st);
//     }
//   }

//   Future<void> signOut() async {
//     try {
//       await ref.read(authControllerProvider.notifier).signOut();
//       ref.read(routerControllerProvider.notifier).goToAuth();
//     } catch (e, st) {
//       state = AsyncError(e, st);
//     }
//   }
// }

@riverpod
class WaitingApprovalController extends _$WaitingApprovalController {
  Timer? _refreshTimer;
  static const adminEmail = 'admin@yourapp.com';
  static const supportPhone = '+12345678900';

  @override
  bool build() {
    ref.onDispose(() {
      _refreshTimer?.cancel();
    });
    return false; // not checking initially
  }

  Future<void> startPeriodicRefresh() async {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => checkApprovalStatus(),
    );
  }

  Future<void> checkApprovalStatus() async {
    if (state) return; // Already checking

    state = true; // Start checking
    try {
      await ref.read(authControllerProvider.notifier).reload();
    } finally {
      state = false; // Done checking
    }
  }

  String getEmailBody() {
    final user = ref.read(authControllerProvider).value;
    if (user == null) return '';

    return '''
Account Approval Request

User Details:
Name: ${user.name}
Email: ${user.email}
ID: ${user.id}

I recently signed up for the app and am awaiting approval. Please review my account.

Thank you.''';
  }

  Future<void> signOut() async {
    await ref.read(authControllerProvider.notifier).signOut();
    ref.read(routerControllerProvider.notifier).goToAuth();
  }

  String getAdminEmail() => adminEmail;
  String getSupportPhone() => supportPhone;
}
