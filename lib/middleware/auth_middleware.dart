import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';

class AuthMiddleware {
  final UserService _userService = UserService();

  Future<bool> checkAuth(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return false;
    }

    final isApproved = await _userService.isUserApproved(user.uid);

    if (!isApproved) {
      Navigator.pushReplacementNamed(context, '/pending-approval');
      return false;
    }

    return true;
  }
}
