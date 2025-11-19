// lib/widgets/logo_widget.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LogoWidget extends StatelessWidget {
  final double? fontSize;
  final Color? color;
  final bool showTagline;
  
  const LogoWidget({
    Key? key,
    this.fontSize,
    this.color,
    this.showTagline = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoColor = color ?? (isDark ? AppColors.white : AppColors.primary);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.professionalGradient,
            borderRadius: BorderRadius.circular(10),
            boxShadow: AppColors.cardShadow,
          ),
          child: Icon(
            Icons.trending_up,
            color: Colors.white,
            size: fontSize != null ? fontSize! * 0.8 : 24,
          ),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Elevare',
              style: TextStyle(
                fontSize: fontSize ?? 24,
                fontWeight: FontWeight.bold,
                color: logoColor,
                letterSpacing: 1.2,
              ),
            ),
            if (showTagline)
              Text(
                'Elevate Your Portfolio',
                style: TextStyle(
                  fontSize: (fontSize ?? 24) * 0.5,
                  color: isDark ? AppColors.lightGray : AppColors.mediumGray,
                  fontWeight: FontWeight.w300,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

