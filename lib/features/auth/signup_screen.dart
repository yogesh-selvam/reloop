import 'package:flutter/material.dart';

import '../../main.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firestore_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final collegeController = TextEditingController();
  final departmentController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    collegeController.dispose();
    departmentController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final college = collegeController.text.trim();
    final department = departmentController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        college.isEmpty ||
        department.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters.'),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = await _authService.signup(
        email: email,
        password: password,
      );

      if (user == null) {
        throw Exception('Unable to create account.');
      }

      await _firestoreService.createUserProfile(
        uid: user.uid,
        name: name,
        email: email,
        college: college,
        department: department,
      );

      await user.sendEmailVerification();
      await _authService.logout();

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Account Created 🎉'),
          content: const Text(
            'A verification link has been sent to your college email.\n\n'
                'Please verify your email before logging in to ReLoop.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(44, 25, 44, 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ReLoopLogo(compact: true),
              const SizedBox(height: 55),
              const Text(
                'Join ReLoop',
                style: TextStyle(
                  fontSize: 39,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Create your verified campus account.',
                style: TextStyle(
                  fontSize: 20,
                  color: muted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),

              const Label('Full Name'),
              InputBox(
                controller: nameController,
                icon: Icons.person_outline,
                hint: 'Enter your full name',
              ),
              const SizedBox(height: 30),

              const Label('College Email'),
              InputBox(
                controller: emailController,
                icon: Icons.school_outlined,
                hint: 'name@university.edu',
              ),
              const SizedBox(height: 30),

              const Label('College'),
              InputBox(
                controller: collegeController,
                icon: Icons.account_balance_outlined,
                hint: 'Enter your college name',
              ),
              const SizedBox(height: 30),

              const Label('Department'),
              InputBox(
                controller: departmentController,
                icon: Icons.menu_book_outlined,
                hint: 'Example: Computer Science',
              ),
              const SizedBox(height: 30),

              const Label('Password'),
              InputBox(
                controller: passwordController,
                icon: Icons.lock_outline_rounded,
                hint: 'Minimum 6 characters',
                obscure: true,
              ),
              const SizedBox(height: 30),

              const Label('Confirm Password'),
              InputBox(
                controller: confirmPasswordController,
                icon: Icons.lock_outline_rounded,
                hint: 'Re-enter your password',
                obscure: true,
              ),
              const SizedBox(height: 42),

              PrimaryButton(
                text: isLoading ? 'Creating Account...' : 'Create Account',
                onTap: isLoading ? () {} : signup,
              ),
              const SizedBox(height: 25),

              Center(
                child: TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: green,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD9E2FF),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      color: green,
                      size: 30,
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        'You must verify your college email before accessing ReLoop.',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
