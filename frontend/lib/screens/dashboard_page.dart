// lib/screens/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/theme_service.dart';

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
        backgroundColor: Color(0xFF667eea),
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
        label: Text('New Portfolio'),
        backgroundColor: Color(0xFF667eea),
      ),
    );
  }
  
  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.grey[100],
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Elevare',
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  Provider.of<AuthService>(context).user?['username'] ?? '',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard, color: Color(0xFF667eea)),
            title: Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
            selected: true,
            selectedTileColor: Colors.blue[50],
          ),
          ListTile(
            leading: Icon(Icons.web),
            title: Text('Portfolios'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.palette),
            title: Text('Templates'),
            onTap: () => Navigator.pushNamed(context, '/templates'),
          ),
          ListTile(
            leading: Icon(Icons.analytics),
            title: Text('Analytics'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMainContent() {
    return Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Portfolios',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.web_asset_off, size: 100, color: Colors.grey[300]),
          SizedBox(height: 20),
          Text(
            'No portfolios yet',
            style: TextStyle(fontSize: 24, color: Colors.grey[600]),
          ),
          SizedBox(height: 12),
          Text(
            'Create your first portfolio to get started',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
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
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/builder', arguments: portfolio['id']),
                borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Icon(Icons.web, size: 60, color: Colors.white70),
              ),
            ),
            Padding(
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
                        color: portfolio['isPublished'] ? Colors.green : Colors.grey,
                      ),
                      SizedBox(width: 4),
                      Text(
                        portfolio['isPublished'] ? 'Published' : 'Draft',
                        style: TextStyle(
                          color: portfolio['isPublished'] ? Colors.green : Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Updated ${_formatDate(portfolio['updatedAt'])}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
          ],
        ),
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
