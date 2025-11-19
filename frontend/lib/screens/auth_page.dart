// lib/screens/auth_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/logo_widget.dart';
import '../widgets/monkey_password_field.dart';
import '../theme/app_colors.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  bool _isLoading = false;
  bool _hasPasswordError = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.professionalGradient,
        ),
        child: Center(
          child: Container(
            width: 450,
            padding: EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.elevatedShadow,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LogoWidget(fontSize: 32, showTagline: false),
                  SizedBox(height: 32),
                  Text(
                    isLogin ? 'Welcome Back' : 'Create Account',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 32),
                  if (!isLogin) ...[
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: Icon(Icons.alternate_email),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (v) => v!.isEmpty || !v.contains('@') ? 'Invalid email' : null,
                  ),
                  SizedBox(height: 16),
                  MonkeyPasswordField(
                    controller: _passwordController,
                    hasError: _hasPasswordError,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Password is required';
                      }
                      if (v.length < 6) {
                        return 'Min 6 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            minimumSize: Size(double.infinity, 50),
                            elevation: 2,
                          ),
                          child: Text(isLogin ? 'Login' : 'Register', style: TextStyle(fontSize: 18)),
                        ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () => setState(() => isLogin = !isLogin),
                    child: Text(
                      isLogin ? 'Need an account? Register' : 'Have an account? Login',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _hasPasswordError = false;
    });
    
    final authService = Provider.of<AuthService>(context, listen: false);
    bool success;
    
    if (isLogin) {
      success = await authService.login(_emailController.text, _passwordController.text);
    } else {
      success = await authService.register(
        _emailController.text,
        _usernameController.text,
        _passwordController.text,
        _fullNameController.text,
      );
    }
    
    setState(() => _isLoading = false);
    
    if (success) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      setState(() => _hasPasswordError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication failed'),
          backgroundColor: Colors.red,
        ),
      );
      // Reset error after animation
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _hasPasswordError = false);
        }
      });
    }
  }
}