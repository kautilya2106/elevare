// lib/widgets/monkey_password_field.dart
import 'package:flutter/material.dart';

class MonkeyPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String labelText;
  final bool hasError;

  const MonkeyPasswordField({
    Key? key,
    required this.controller,
    this.validator,
    this.labelText = 'Password',
    this.hasError = false,
  }) : super(key: key);

  @override
  _MonkeyPasswordFieldState createState() => _MonkeyPasswordFieldState();
}

class _MonkeyPasswordFieldState extends State<MonkeyPasswordField>
    with SingleTickerProviderStateMixin {
  bool _obscureText = true;
  bool _isFocused = false;
  late AnimationController _monkeyController;
  late Animation<double> _eyeAnimation;
  late Animation<double> _shakeAnimation;
  String _lastPassword = '';

  @override
  void initState() {
    super.initState();
    _monkeyController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _eyeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _monkeyController, curve: Curves.easeInOut),
    );
    
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 10.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: -10.0, end: 0.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _monkeyController, curve: Curves.easeInOut),
    );
    
    widget.controller.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPasswordChanged);
    _monkeyController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    final currentPassword = widget.controller.text;
    
    // If error state, shake and show "no"
    if (widget.hasError && currentPassword.isNotEmpty) {
      _monkeyController.forward();
    } else if (_isFocused && currentPassword.length > _lastPassword.length) {
      // If password is being typed and field is focused, close eyes
      _monkeyController.forward();
    } else if (currentPassword.isEmpty && !widget.hasError) {
      _monkeyController.reverse();
    }
    
    _lastPassword = currentPassword;
  }
  
  @override
  void didUpdateWidget(MonkeyPasswordField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasError && !oldWidget.hasError) {
      // Error just occurred, trigger shake animation
      _monkeyController.reset();
      _monkeyController.forward().then((_) {
        Future.delayed(Duration(milliseconds: 800), () {
          if (mounted && !widget.hasError) {
            _monkeyController.reverse();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                obscureText: _obscureText,
                validator: widget.validator,
                onTap: () {
                  setState(() => _isFocused = true);
                  if (widget.controller.text.isNotEmpty) {
                    _monkeyController.forward();
                  }
                },
                onFieldSubmitted: (_) {
                  setState(() => _isFocused = false);
                  _monkeyController.reverse();
                },
                decoration: InputDecoration(
                  labelText: widget.labelText,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() => _obscureText = !_obscureText);
                    },
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            AnimatedBuilder(
              animation: _monkeyController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    widget.hasError ? _shakeAnimation.value : 0,
                    0,
                  ),
                  child: Container(
                    width: 80,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Monkey face
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Color(0xFF8B4513),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.brown.shade700, width: 2),
                          ),
                        ),
                        // Eyes
                        if (!widget.hasError)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Left eye
                              Container(
                                margin: EdgeInsets.only(right: 8),
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Container(
                                    width: 8,
                                    height: 8 * (1 - _eyeAnimation.value),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                              // Right eye
                              Container(
                                margin: EdgeInsets.only(left: 8),
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Container(
                                    width: 8,
                                    height: 8 * (1 - _eyeAnimation.value),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        // "No" text when error
                        if (widget.hasError)
                          Text(
                            'NO',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        // Mouth
                        Positioned(
                          bottom: 12,
                          child: Container(
                            width: 20,
                            height: widget.hasError ? 8 : 4,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        if (widget.hasError)
          Padding(
            padding: EdgeInsets.only(top: 8, left: 16),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 16),
                SizedBox(width: 4),
                Text(
                  'Wrong password!',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

