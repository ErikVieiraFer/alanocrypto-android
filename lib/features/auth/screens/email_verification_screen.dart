// DESABILITADO - Fluxo direto sem verificação de email

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../services/email_verification_service.dart';
//
// class EmailVerificationScreen extends StatefulWidget {
//   final String email;
//   final String displayName;
//
//   const EmailVerificationScreen({
//     super.key,
//     required this.email,
//     required this.displayName,
//   });
//
//   @override
//   State<EmailVerificationScreen> createState() =>
//       _EmailVerificationScreenState();
// }
//
// class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
//   final EmailVerificationService _verificationService =
//       EmailVerificationService();
//   final List<TextEditingController> _controllers =
//       List.generate(6, (_) => TextEditingController());
//   final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
//
//   bool _isLoading = false;
//   bool _canResend = false;
//   int _resendCountdown = 60;
//   Timer? _timer;
//
//   @override
//   void initState() {
//     super.initState();
//     _sendCode();
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     for (var node in _focusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }
//
//   void _startCountdown() {
//     _canResend = false;
//     _resendCountdown = 60;
//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         if (_resendCountdown > 0) {
//           _resendCountdown--;
//         } else {
//           _canResend = true;
//           timer.cancel();
//         }
//       });
//     });
//   }
//
//   Future<void> _sendCode() async {
//     setState(() => _isLoading = true);
//
//     final success = await _verificationService.sendVerificationCode(
//       widget.email,
//       widget.displayName,
//     );
//
//     setState(() => _isLoading = false);
//
//     if (mounted) {
//       if (success) {
//         _startCountdown();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Código enviado para seu email')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Erro ao enviar código')),
//         );
//       }
//     }
//   }
//
//   Future<void> _verifyCode() async {
//     final code = _controllers.map((c) => c.text).join();
//
//     if (code.length != 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Digite o código completo')),
//       );
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     final isValid = await _verificationService.verifyCode(widget.email, code);
//
//     if (mounted) {
//       if (isValid) {
//         // Atualizar Firestore
//         final user = FirebaseAuth.instance.currentUser;
//         if (user != null) {
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(user.uid)
//               .update({'emailVerified': true});
//
//           // Redirecionar para pending approval
//           if (mounted) {
//             Navigator.pushReplacementNamed(context, '/pending-approval');
//           }
//         }
//       } else {
//         setState(() => _isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Código inválido ou expirado')),
//         );
//         // Limpar campos
//         for (var controller in _controllers) {
//           controller.clear();
//         }
//         _focusNodes[0].requestFocus();
//       }
//     }
//   }
//
//   Future<void> _cancel() async {
//     await FirebaseAuth.instance.signOut();
//     if (mounted) {
//       Navigator.pushReplacementNamed(context, '/login');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Verificação de Email'),
//         automaticallyImplyLeading: false,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.email_outlined,
//                 size: 80,
//                 color: Colors.blue,
//               ),
//               const SizedBox(height: 24),
//               const Text(
//                 'Verifique seu Email',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 'Código enviado para:',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey[600],
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 widget.email,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 32),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(6, (index) {
//                   return Container(
//                     margin: EdgeInsets.only(
//                       right: index < 5 ? 8 : 0,
//                     ),
//                     width: 45,
//                     child: TextField(
//                       controller: _controllers[index],
//                       focusNode: _focusNodes[index],
//                       maxLength: 1,
//                       textAlign: TextAlign.center,
//                       keyboardType: TextInputType.number,
//                       decoration: const InputDecoration(
//                         counterText: '',
//                         border: OutlineInputBorder(),
//                       ),
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       onChanged: (value) {
//                         if (value.length == 1) {
//                           if (index < 5) {
//                             _focusNodes[index + 1].requestFocus();
//                           } else {
//                             // Auto-verificar ao digitar 6º dígito
//                             _verifyCode();
//                           }
//                         } else if (value.isEmpty && index > 0) {
//                           _focusNodes[index - 1].requestFocus();
//                         }
//                       },
//                     ),
//                   );
//                 }),
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _verifyCode,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : const Text('Verificar'),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextButton(
//                 onPressed: _canResend && !_isLoading ? _sendCode : null,
//                 child: Text(
//                   _canResend
//                       ? 'Reenviar código'
//                       : 'Reenviar código em ${_resendCountdown}s',
//                 ),
//               ),
//               const SizedBox(height: 32),
//               TextButton(
//                 onPressed: _isLoading ? null : _cancel,
//                 child: const Text('Cancelar'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
