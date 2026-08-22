import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({
    super.key,
    required this.email,
  });

  final String email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  bool isChecking = false;
  bool canResend = true;
  int resendSeconds = 0;

  Timer? _timer;

  static const Color green = Color(0xFF2E7D32);
  static const Color darkText = Color(0xFF182018);
  static const Color muted = Color(0xFF667066);
  static const Color lightGreen = Color(0xFFEAF6EA);

  Future<void> resendVerification() async {
    if (!canResend) return;

    setState(() => isLoading = true);

    try {
      await _authService.resendVerificationEmail();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verification email sent. Check your inbox and spam folder.',
          ),
        ),
      );

      _startTimer();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Unable to send verification email.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();

    setState(() {
      canResend = false;
      resendSeconds = 30;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (resendSeconds <= 1) {
          timer.cancel();

          setState(() {
            canResend = true;
            resendSeconds = 0;
          });
        } else {
          setState(() {
            resendSeconds--;
          });
        }
      },
    );
  }

  Future<void> checkVerification() async {
    if (isChecking) return;

    setState(() => isChecking = true);

    try {
      final verified = await _authService.isEmailVerified();

      if (!mounted) return;

      if (verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verified successfully! 🎉'),
          ),
        );

        await Future.delayed(
          const Duration(milliseconds: 500),
        );

        if (!mounted) return;

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Email is not verified yet. Please check your email.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isChecking = false);
      }
    }
  }

  Future<void> backToLogin() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            30,
            50,
            30,
            30,
          ),
          child: Column(
            children: [
              const Text(
                'ReLoop',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: green,
                ),
              ),

              const SizedBox(height: 60),

              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  size: 55,
                  color: green,
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                'Verify Your Email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'We sent a verification link to:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: muted,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                widget.email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: green,
                ),
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD9E2FF),
                  ),
                ),
                child: const Text(
                  'Open your email and click the verification link. '
                      'After verifying, return here and tap '
                      '"I\'ve Verified My Email".',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: muted,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: double.infinity,
                height: 68,
                child: ElevatedButton(
                  onPressed:
                  isChecking ? null : checkVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: isChecking
                      ? const SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                      : const Text(
                    'I\'ve Verified My Email',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 65,
                child: OutlinedButton(
                  onPressed:
                  isLoading || !canResend
                      ? null
                      : resendVerification,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: green,
                    side: const BorderSide(
                      color: green,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
                    canResend
                        ? 'Resend Verification Email'
                        : 'Resend in ${resendSeconds}s',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              TextButton(
                onPressed: backToLogin,
                child: const Text(
                  'Back to Login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: muted,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Didn\'t receive the email?\n'
                    'Check your spam or junk folder.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}