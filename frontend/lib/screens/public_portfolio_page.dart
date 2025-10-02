// lib/screens/public_portfolio_page.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
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
    
    return Container(
      padding: EdgeInsets.all(60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content.entries.map((entry) {
          return Container(
            margin: EdgeInsets.only(bottom: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (entry.value['title'] ?? entry.key).toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  entry.value['text']?.toString() ?? 'Content here',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                    height: 1.6,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildFooter(bool isDark) {
    return Container(
      padding: EdgeInsets.all(40),
      color: isDark ? Colors.black : Colors.grey[100],
      child: Center(
        child: Column(
          children: [
            Text(
              'Powered by Elevare',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: Text('Create your own portfolio'),
            ),
          ],
        ),
      ),
    );
  }
}