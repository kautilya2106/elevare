// lib/screens/templates_page.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/logo_widget.dart';
import '../theme/app_colors.dart';

class TemplatesPage extends StatefulWidget {
  @override
  _TemplatesPageState createState() => _TemplatesPageState();
}

class _TemplatesPageState extends State<TemplatesPage> {
  List<dynamic> _templates = [];
  List<dynamic> _filteredTemplates = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadTemplates();
    _searchController.addListener(_filterTemplates);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _filterTemplates() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredTemplates = _templates.where((template) {
        final matchesCategory = _selectedCategory == 'All' || 
            template['category'] == _selectedCategory;
        final matchesSearch = query.isEmpty ||
            (template['name']?.toString().toLowerCase().contains(query) ?? false) ||
            (template['description']?.toString().toLowerCase().contains(query) ?? false);
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }
  
  Future<void> _loadTemplates() async {
    try {
      final templates = await ApiService.getList('/templates');
      setState(() {
        _templates = templates;
        _filteredTemplates = templates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: LogoWidget(fontSize: 20, showTagline: false, color: Colors.white),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: Container(
              color: AppColors.white,
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildTemplateGrid(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search templates...',
          prefixIcon: Icon(Icons.search),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.veryLightGray,
        ),
        onChanged: (_) => _filterTemplates(),
      ),
    );
  }
  
  Widget _buildCategoryFilter() {
    final categories = ['All', 'Modern', 'Creative', 'Professional', 'Minimal'];
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((cat) {
            final isSelected = _selectedCategory == cat;
            return Padding(
              padding: EdgeInsets.only(right: 12),
              child: FilterChip(
                label: Text(cat),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = cat;
                    _filterTemplates();
                  });
                },
                backgroundColor: AppColors.veryLightGray,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.dark,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  
  IconData _getTemplateIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'developer':
        return Icons.code;
      case 'designer':
        return Icons.palette;
      case 'writer':
        return Icons.edit;
      case 'photographer':
        return Icons.camera_alt;
      case 'business':
        return Icons.business;
      case 'creative':
        return Icons.brush;
      default:
        return Icons.web;
    }
  }
  
  Widget _buildTemplateGrid() {
    if (_filteredTemplates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.lightGray),
            SizedBox(height: 16),
            Text(
              'No templates found',
              style: TextStyle(fontSize: 16, color: AppColors.mediumGray, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'Try a different search or category',
              style: TextStyle(fontSize: 14, color: AppColors.lightGray),
            ),
          ],
        ),
      );
    }
    
    return GridView.builder(
      padding: EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredTemplates.length,
      itemBuilder: (context, index) => _buildTemplateCard(_filteredTemplates[index]),
    );
  }
  
  Widget _buildTemplateCard(Map<String, dynamic> template) {
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
              child: InkWell(
                onTap: () => _showTemplatePreview(template),
                borderRadius: BorderRadius.circular(12),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: AppColors.professionalGradient,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                                        Colors.white.withOpacity(0.15),
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
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Icon(
                                        _getTemplateIcon(template['category']),
                                        size: 64,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      template['name'] ?? 'Template',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
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
                        if (template['isFeatured'])
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'FEATURED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template['name'] ?? 'Template',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Text(
                            template['description'] ?? '',
                            style: TextStyle(fontSize: 14, color: AppColors.mediumGray),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${template['downloads'] ?? 0} downloads',
                                style: TextStyle(fontSize: 12, color: AppColors.lightGray),
                              ),
                              ElevatedButton(
                                onPressed: () => _useTemplate(template),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                                child: Text('Use Template', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  void _showTemplatePreview(Map<String, dynamic> template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          template['name'] ?? 'Template',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (template['isFeatured'])
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'FEATURED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Chip(
                    label: Text(template['category'] ?? 'Uncategorized'),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                  ),
                  SizedBox(height: 16),
                  Text(
                    template['description'] ?? '',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(Icons.download, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        '${template['downloads'] ?? 0} downloads',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _useTemplate(template);
                      },
                      icon: Icon(Icons.add),
                      label: Text('Use This Template'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _useTemplate(Map<String, dynamic> template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Use Template'),
        content: Text('Start a new portfolio with "${template['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/builder', arguments: template['id']);
            },
            child: Text('Create Portfolio'),
          ),
        ],
      ),
    );
  }
}