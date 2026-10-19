import 'package:ecommerce_app/core/app_colors.dart';
import 'package:ecommerce_app/core/app_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final error =
        await context.read<AuthProvider>().login(_email.text, _password.text);

    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.home, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            // Keeps the form narrow and centered on big screens
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.shopping_bag_rounded,
                        size: 56, color: AppColors.primary),
                    const SizedBox(height: 24),
                    const Text('Welcome back',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    const Text('Login to continue shopping',
                        style: TextStyle(color: AppColors.textLight)),
                    const SizedBox(height: 32),
                    CustomTextField(
                      controller: _email,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Enter a valid email'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _password,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Minimum 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                        text: 'Login', onPressed: _submit, isLoading: _loading),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.register),
                        child: const Text("Don't have an account? Register"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}