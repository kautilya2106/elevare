// lib/screens/templates_page.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
        title: Text('Template Marketplace'),
        backgroundColor: Color(0xFF667eea),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _buildTemplateGrid(),
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
          fillColor: Colors.grey[100],
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
                backgroundColor: Colors.grey[200],
                selectedColor: Color(0xFF667eea),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildTemplateGrid() {
    if (_filteredTemplates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No templates found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Try a different search or category',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                onTap: () => _showTemplatePreview(template),
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 200,
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
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Text(
                            template['description'] ?? '',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${template['downloads'] ?? 0} downloads',
                                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                              ),
                              ElevatedButton(
                                onPressed: () => _useTemplate(template),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF667eea),
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
                    backgroundColor: Color(0xFF667eea).withOpacity(0.1),
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