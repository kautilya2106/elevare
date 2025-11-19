// lib/screens/public_portfolio_page.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/logo_widget.dart';
import '../theme/app_colors.dart';

class PublicPortfolioPage extends StatefulWidget {
  final String slug;
  
  PublicPortfolioPage({required this.slug});
  
  @override
  _PublicPortfolioPageState createState() => _PublicPortfolioPageState();
}

class _PublicPortfolioPageState extends State<PublicPortfolioPage> {
  Map<String, dynamic>? _portfolio;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }
  
  Future<void> _loadPortfolio() async {
    try {
      final portfolio = await ApiService.get('/portfolios/${widget.slug}');
      setState(() {
        _portfolio = portfolio;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Error is already handled by showing "Portfolio not found" message
      print('Error loading portfolio: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_portfolio == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'Portfolio not found',
                style: TextStyle(fontSize: 24, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
    
    final isDark = _portfolio!['theme'] == 'dark';
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(isDark),
            _buildContent(isDark),
            _buildFooter(isDark),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.all(60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Column(
        children: [
          Text(
            _portfolio!['title'] ?? '',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'By ${_portfolio!['author']['fullName'] ?? _portfolio!['author']['username']}',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContent(bool isDark) {
    final content = _portfolio!['content'] as Map<String, dynamic>?;
    if (content == null) return SizedBox();
    
    // Get sections list if available, otherwise use content keys
    final sections = (content['sections'] as List?)?.map((e) => e.toString()).toList() ?? 
                     content.keys.where((k) => k != 'sections').toList();
    
    return Container(
      padding: EdgeInsets.all(60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections.map((sectionKey) {
          final sectionData = content[sectionKey] as Map<String, dynamic>?;
          if (sectionData == null) return SizedBox();
          
          return Container(
            margin: EdgeInsets.only(bottom: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (sectionData['title'] ?? sectionKey).toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 24),
                if (sectionKey == 'contact')
                  _buildContactSection(sectionData, isDark)
                else if (sectionKey == 'experience')
                  _buildExperienceSection(sectionData, isDark)
                else if (sectionData['text'] != null)
                  Text(
                    sectionData['text'].toString(),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1.6,
                    ),
                  )
                else if (sectionData['items'] != null)
                  _buildItemsList(sectionData['items'], isDark)
                else
                  Text(
                    'Content here',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildExperienceSection(Map<String, dynamic> sectionData, bool isDark) {
    final experiences = (sectionData['items'] as List?) ?? [];
    if (experiences.isEmpty) {
      return Text(
        'No experience listed',
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white70 : Colors.grey[600],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: experiences.map<Widget>((exp) {
        final company = exp['company']?.toString() ?? '';
        final position = exp['position']?.toString() ?? '';
        final startDate = exp['startDate']?.toString() ?? '';
        final endDate = exp['endDate']?.toString() ?? '';
        final location = exp['location']?.toString() ?? '';
        final description = exp['description']?.toString() ?? '';
        
        return Container(
          margin: EdgeInsets.only(bottom: 32),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF1E1E1E) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (position.isNotEmpty)
                Text(
                  position,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              if (company.isNotEmpty) ...[
                SizedBox(height: 4),
                Text(
                  company,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (startDate.isNotEmpty || endDate.isNotEmpty || location.isNotEmpty) ...[
                SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    if (startDate.isNotEmpty || endDate.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text(
                            endDate.isEmpty 
                                ? startDate 
                                : '$startDate - $endDate',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    if (location.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, size: 16, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text(
                            location,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
              if (description.isNotEmpty) ...[
                SizedBox(height: 16),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                    height: 1.6,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildContactSection(Map<String, dynamic> sectionData, bool isDark) {
    final email = sectionData['email']?.toString();
    final phone = sectionData['phone']?.toString();
    final location = sectionData['location']?.toString();
    
    if ((email?.isEmpty ?? true) && (phone?.isEmpty ?? true) && (location?.isEmpty ?? true)) {
      return Text(
        'No contact information provided',
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white70 : Colors.grey[600],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (email?.isNotEmpty ?? false)
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Icon(Icons.email, color: AppColors.primary, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    email!,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (phone?.isNotEmpty ?? false)
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Icon(Icons.phone, color: AppColors.primary, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    phone!,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (location?.isNotEmpty ?? false)
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primary, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  location!,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
  
  Widget _buildItemsList(dynamic items, bool isDark) {
    if (items is! List || items.isEmpty) {
      return Text(
        'No items yet',
        style: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white70 : Colors.grey[600],
        ),
      );
    }
    
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: items.map<Widget>((item) {
        if (item is Map) {
          return Card(
            elevation: 2,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item['name'] != null)
                    Text(
                      item['name'].toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  if (item['description'] != null) ...[
                    SizedBox(height: 8),
                    Text(
                      item['description'].toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                      ),
                    ),
                  ],
                  if (item['url'] != null && item['url'].toString().isNotEmpty) ...[
                    SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        // Could open URL in browser
                      },
                      child: Text(
                        item['url'].toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        } else {
          return Chip(
            label: Text(
              item.toString(),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: AppColors.primary.withOpacity(0.15),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          );
        }
      }).toList(),
    );
  }
  
  Widget _buildFooter(bool isDark) {
    return Container(
      padding: EdgeInsets.all(40),
      color: isDark ? Colors.black : Colors.grey[100],
      child: Center(
        child: Column(
          children: [
            LogoWidget(
              fontSize: 24,
              showTagline: false,
              color: isDark ? Colors.white : AppColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              'Create your own stunning portfolio',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to landing page or auth
              },
              icon: Icon(Icons.add),
              label: Text('Get Started'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}