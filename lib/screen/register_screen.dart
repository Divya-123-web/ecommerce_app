import 'package:ecommerce_app/core/app_colors.dart';
import 'package:ecommerce_app/core/app_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final error = await context
        .read<AuthProvider>()
        .register(_name.text, _email.text, _password.text);

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
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Create account',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    const Text('Join ShopEasy today',
                        style: TextStyle(color: AppColors.textLight)),
                    const SizedBox(height: 28),
                    CustomTextField(
                      controller: _name,
                      label: 'Full name',
                      icon: Icons.person_outline,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter your name'
                          : null,
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _confirm,
                      label: 'Confirm password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: (v) =>
                          v != _password.text ? 'Passwords do not match' : null,
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                        text: 'Register',
                        onPressed: _submit,
                        isLoading: _loading),
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