// lib/screens/landing_page.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../widgets/logo_widget.dart';
import '../theme/app_colors.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _rotateController;
  
  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _rotateController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _floatController.dispose();
    _rotateController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildHeroSection(),
            _buildHowItWorks(),
            _buildTemplatePreview(),
            _buildTestimonials(),
            _buildAboutUs(),
            _buildContact(),
            _buildFAQ(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          LogoWidget(fontSize: 28, showTagline: false),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/templates'),
                child: Text('Templates', style: TextStyle(fontSize: 16)),
              ),
              SizedBox(width: 16),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/auth'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text('Sign In'),
              ),
              SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/auth'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text('Get Started'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeroSection() {
    return Container(
      height: 900,
      decoration: BoxDecoration(
        gradient: AppColors.professionalGradient,
      ),
      child: Stack(
        children: [
          // Multiple animated 3D shapes for more interactivity
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              return Positioned(
                top: 100 + _floatController.value * 50,
                right: 100,
                child: Transform.rotate(
                  angle: _rotateController.value * 2 * math.pi,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 30,
                          offset: Offset(0, 15),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              return Positioned(
                bottom: 150 + _floatController.value * 30,
                left: 80,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Additional floating element
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              return Positioned(
                top: 200 + (1 - _floatController.value) * 40,
                left: 150,
                child: Transform.rotate(
                  angle: -_rotateController.value * math.pi,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.05)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Hero content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LogoWidget(fontSize: 64, showTagline: false, color: Colors.white),
                SizedBox(height: 32),
                Text(
                  'Elevate Your Portfolio',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 20,
                        color: Colors.black45,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Text(
                  'Create stunning portfolios in minutes',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white.withOpacity(0.95),
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  '100% Free • No Credit Card Required',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/auth'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(horizontal: 60, vertical: 24),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Start Building Now',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.arrow_forward, size: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '✓ No signup required to browse templates',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHowItWorks() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        children: [
          Text(
            'How It Works',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStep('1', 'Choose Template', 'Select from our curated collection', Icons.palette),
              _buildStep('2', 'Customize', 'Drag and drop your content', Icons.edit),
              _buildStep('3', 'Publish', 'Share your portfolio with the world', Icons.rocket_launch),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStep(String number, String title, String description, IconData icon) {
    return Container(
      width: 300,
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
                      gradient: AppColors.professionalGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 40),
          ),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildTemplatePreview() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: Colors.grey[50],
      child: Column(
        children: [
          Text(
            'Beautiful Templates',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 60),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildTemplateCard('Modern', 'Clean and minimal design'),
              _buildTemplateCard('Creative', 'Bold and expressive'),
              _buildTemplateCard('Professional', 'Corporate ready'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTemplateCard(String name, String description) {
    bool isHovered = false;
    return StatefulBuilder(
      builder: (context, setState) => MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: 350,
          height: 400,
          transform: Matrix4.identity()..translate(0.0, isHovered ? -10.0 : 0.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isHovered ? Colors.black26 : Colors.black12,
                blurRadius: isHovered ? 30 : 20,
                offset: Offset(0, isHovered ? 15 : 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 280,
                decoration: BoxDecoration(
                      gradient: AppColors.professionalGradient,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Center(
                  child: Icon(Icons.web, size: 80, color: Colors.white70),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
  
  Widget _buildTestimonials() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        children: [
          Text(
            'What Our Users Say',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTestimonial(
                'Amazing platform! Created my portfolio in under an hour.',
                'Sarah Johnson',
                'Designer',
              ),
              _buildTestimonial(
                'The templates are stunning and easy to customize.',
                'Michael Chen',
                'Developer',
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildTestimonial(String text, String name, String role) {
    return Container(
      width: 400,
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '"$text"',
            style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            role,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPricing() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: Colors.grey[50],
      child: Column(
        children: [
          Text(
            'Simple Pricing',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPricingCard('Free', '0', ['1 Portfolio', 'Basic Templates', 'Community Support'], false),
              SizedBox(width: 20),
              _buildPricingCard('Pro', '19', ['Unlimited Portfolios', 'Premium Templates', 'Priority Support', 'Custom Domain'], true),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPricingCard(String name, String price, List<String> features, bool highlighted) {
    return Container(
      width: 350,
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
                    color: highlighted ? AppColors.primary : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: highlighted ? null : Border.all(color: Colors.grey[300]!),
        boxShadow: highlighted
            ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 30, offset: Offset(0, 15))]
            : [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Column(
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: highlighted ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\$',
                style: TextStyle(
                  fontSize: 24,
                  color: highlighted ? Colors.white : Colors.black,
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: highlighted ? Colors.white : Colors.black,
                ),
              ),
              Text(
                '/mo',
                style: TextStyle(
                  fontSize: 24,
                  color: highlighted ? Colors.white70 : Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          ...features.map((f) => Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: highlighted ? AppColors.white : AppColors.primary,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      f,
                      style: TextStyle(
                        fontSize: 16,
                        color: highlighted ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              )),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/auth'),
            style: ElevatedButton.styleFrom(
              backgroundColor: highlighted ? AppColors.white : AppColors.primary,
              foregroundColor: highlighted ? AppColors.primary : AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            ),
            child: Text('Get Started', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAboutUs() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: Colors.grey[50],
      child: Container(
        constraints: BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            Text(
              'About Us',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                      gradient: AppColors.professionalGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(Icons.rocket_launch, size: 80, color: Colors.white),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Our Mission',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'At Elevare, we believe everyone deserves a beautiful portfolio to showcase their work. Our mission is to democratize portfolio creation by providing a free, easy-to-use platform that empowers creators, developers, designers, and professionals to build stunning portfolios without any technical knowledge.',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.6),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 40),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.secondary],
                  ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(Icons.favorite, size: 80, color: Colors.white),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Why Elevare?',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'We\'re committed to keeping Elevare 100% free forever. No hidden costs, no premium tiers, no credit card required. We provide all features, all templates, and unlimited portfolios to everyone. Your success is our success, and we\'re here to help you elevate your professional presence.',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.6),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 40),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                  ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(Icons.people, size: 80, color: Colors.white),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Our Community',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Join thousands of creators who trust Elevare to showcase their work. From developers and designers to photographers and writers, our platform serves professionals across all industries. We\'re constantly improving based on your feedback.',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContact() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Container(
        constraints: BoxConstraints(maxWidth: 800),
        child: Column(
          children: [
            Text(
              'Get In Touch',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Have questions or feedback? We\'d love to hear from you!',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildContactCard(
                  icon: Icons.email,
                  title: 'Email Us',
                  subtitle: 'support@elevare.com',
                  color: AppColors.primary,
                ),
                SizedBox(width: 40),
                _buildContactCard(
                  icon: Icons.chat_bubble,
                  title: 'Live Chat',
                  subtitle: 'Available 24/7',
                  color: AppColors.primaryDark,
                ),
                SizedBox(width: 40),
                _buildContactCard(
                  icon: Icons.bug_report,
                  title: 'Report Issue',
                  subtitle: 'Help us improve',
                  color: AppColors.secondary,
                ),
              ],
            ),
            SizedBox(height: 40),
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    'Follow Us',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialIcon(Icons.facebook, Color(0xFF1877F2)),
                      SizedBox(width: 16),
                      _buildSocialIcon(Icons.alternate_email, Color(0xFF1DA1F2)),
                      SizedBox(width: 16),
                      _buildSocialIcon(Icons.camera_alt, Color(0xFFE4405F)),
                      SizedBox(width: 16),
                      _buildSocialIcon(Icons.code, Color(0xFF24292E)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContactCard({required IconData icon, required String title, required String subtitle, required Color color}) {
    return Container(
      width: 200,
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: color),
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
  
  Widget _buildFAQ() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        children: [
          Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 60),
          Container(
            constraints: BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                _buildFAQItem('How do I get started?', 'Simply sign up for a free account and start building your portfolio with our intuitive drag-and-drop builder. No credit card required!'),
                _buildFAQItem('Is Elevare really free?', 'Yes! Elevare is 100% free for everyone. Create unlimited portfolios, use all templates, and publish as many times as you want.'),
                _buildFAQItem('Can I use my own domain?', 'Currently, all portfolios are hosted on elevare.com/p/your-slug. Custom domains may be added in future updates.'),
                _buildFAQItem('What features are included?', 'All features! Portfolio builder, all templates, analytics, custom sections, and more. No hidden costs or premium tiers.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            answer,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 40),
      color: AppColors.dark,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Elevare',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text('About', style: TextStyle(color: Colors.white)),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('Contact', style: TextStyle(color: Colors.white)),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('Privacy', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            '© 2025 Elevare. All rights reserved.',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}