// lib/screens/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/theme_service.dart';
import '../widgets/logo_widget.dart';
import '../theme/app_colors.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<dynamic> _portfolios = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadPortfolios();
  }
  
  Future<void> _loadPortfolios() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final portfolios = await ApiService.getList('/portfolios', token: authService.token);
      setState(() {
        _portfolios = portfolios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: AppColors.primary,
        actions: [
          Consumer<ThemeService>(
            builder: (context, themeService, child) {
              return IconButton(
                icon: Icon(
                  themeService.isDarkMode(context) 
                      ? Icons.light_mode 
                      : Icons.dark_mode,
                ),
                tooltip: 'Toggle Theme',
                onPressed: () => themeService.toggleTheme(),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => _showProfileMenu(context),
          ),
        ],
      ),
      body: Row(
        children: [
          _buildSidebar(context),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _buildMainContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/builder'),
        icon: Icon(Icons.add),
        label: Text('New Portfolio', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primary,
        tooltip: 'Create a new portfolio',
        elevation: 4,
      ),
    );
  }
  
  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 250,
      color: AppColors.veryLightGray,
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: AppColors.professionalGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                LogoWidget(fontSize: 24, color: Colors.white, showTagline: false),
                SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        Provider.of<AuthService>(context).user?['username'] ?? '',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard, color: AppColors.primary),
            title: Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.dark)),
            selected: true,
            selectedTileColor: AppColors.primary.withOpacity(0.1),
          ),
          ListTile(
            leading: Icon(Icons.web, color: AppColors.mediumGray),
            title: Text('Portfolios', style: TextStyle(color: AppColors.dark)),
            onTap: () {},
            hoverColor: AppColors.primary.withOpacity(0.05),
          ),
          ListTile(
            leading: Icon(Icons.palette, color: AppColors.mediumGray),
            title: Text('Templates', style: TextStyle(color: AppColors.dark)),
            onTap: () => Navigator.pushNamed(context, '/templates'),
            hoverColor: AppColors.primary.withOpacity(0.05),
          ),
          ListTile(
            leading: Icon(Icons.analytics, color: AppColors.mediumGray),
            title: Text('Analytics', style: TextStyle(color: AppColors.dark)),
            onTap: () {},
            hoverColor: AppColors.primary.withOpacity(0.05),
          ),
          ListTile(
            leading: Icon(Icons.settings, color: AppColors.mediumGray),
            title: Text('Settings', style: TextStyle(color: AppColors.dark)),
            onTap: () => Navigator.pushNamed(context, '/settings'),
            hoverColor: AppColors.primary.withOpacity(0.05),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMainContent() {
    return Container(
      color: AppColors.white,
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Portfolios',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.dark),
          ),
          SizedBox(height: 32),
          _portfolios.isEmpty
              ? _buildEmptyState()
              : Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _portfolios.length,
                    itemBuilder: (context, index) => _buildPortfolioCard(_portfolios[index]),
                  ),
                ),
        ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.web_asset_off, size: 100, color: AppColors.lightGray),
          SizedBox(height: 20),
          Text(
            'No portfolios yet',
            style: TextStyle(fontSize: 24, color: AppColors.mediumGray, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 12),
          Text(
            'Create your first portfolio to get started',
            style: TextStyle(fontSize: 16, color: AppColors.lightGray),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPortfolioCard(Map<String, dynamic> portfolio) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: AppColors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pushNamed(context, '/builder', arguments: portfolio['id']),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        child: Container(
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: AppColors.professionalGradient,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: Stack(
                            children: [
                              // Decorative pattern
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                    gradient: RadialGradient(
                                      center: Alignment.topRight,
                                      radius: 1.5,
                                      colors: [
                                        Colors.white.withOpacity(0.1),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(Icons.web, size: 48, color: Colors.white),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      portfolio['title'] ?? 'Portfolio',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: Colors.white),
                          color: Colors.white,
                          onSelected: (value) {
                            if (value == 'delete') {
                              _deletePortfolio(portfolio['id'], portfolio['title']);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red, size: 20),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(context, '/builder', arguments: portfolio['id']),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              portfolio['title'] ?? 'Untitled',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  portfolio['isPublished'] ? Icons.public : Icons.public_off,
                                  size: 16,
                                  color: portfolio['isPublished'] ? AppColors.success : AppColors.mediumGray,
                                ),
                                SizedBox(width: 4),
                      Text(
                        portfolio['isPublished'] ? 'Published' : 'Draft',
                        style: TextStyle(
                          color: portfolio['isPublished'] ? AppColors.success : AppColors.mediumGray,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                              ],
                            ),
                            SizedBox(height: 8),
                  Text(
                    'Updated ${_formatDate(portfolio['updatedAt'])}',
                    style: TextStyle(fontSize: 12, color: AppColors.mediumGray),
                  ),
                            if (portfolio['isPublished']) ...[
                              SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => _copyPortfolioLink(portfolio['slug']),
                                  icon: Icon(Icons.link, size: 16),
                                  label: Text('Copy Link'),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _copyPortfolioLink(String slug) {
    final link = 'elevare.com/p/$slug';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text('Link copied to clipboard!')),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _deletePortfolio(String portfolioId, String? portfolioTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Portfolio'),
        content: Text('Are you sure you want to delete "${portfolioTitle ?? 'this portfolio'}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performDelete(portfolioId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _performDelete(String portfolioId) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await ApiService.delete('/portfolios/$portfolioId', token: authService.token);
      
      // Reload portfolios list
      await _loadPortfolios();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Portfolio deleted successfully')),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete portfolio: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  
  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'recently';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
      if (diff.inDays > 0) return '${diff.inDays} days ago';
      if (diff.inHours > 0) return '${diff.inHours} hours ago';
      return 'just now';
    } catch (e) {
      return 'recently';
    }
  }
  
  void _showProfileMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Edit Profile'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Provider.of<AuthService>(context, listen: false).logout();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
    );
  }
}
