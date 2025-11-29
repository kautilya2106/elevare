// lib/screens/portfolio_builder_page.dart - FULLY FUNCTIONAL VERSION
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../widgets/logo_widget.dart';
import '../theme/app_colors.dart';

class PortfolioBuilderPage extends StatefulWidget {
  final String? portfolioId;
  
  PortfolioBuilderPage({this.portfolioId});
  
  @override
  _PortfolioBuilderPageState createState() => _PortfolioBuilderPageState();
}

class _PortfolioBuilderPageState extends State<PortfolioBuilderPage> {
  final _titleController = TextEditingController();
  final _slugController = TextEditingController();
  List<String> _sections = ['about', 'experience', 'education', 'projects', 'skills', 'contact'];
  Map<String, dynamic> _content = {
    'about': {'title': 'About Me', 'text': 'I am a passionate developer...'},
    'experience': {'title': 'Experience', 'items': []},
    'education': {'title': 'Education', 'items': []},
    'projects': {'title': 'Projects', 'items': []},
    'skills': {'title': 'Skills', 'items': []},
    'contact': {'title': 'Contact', 'email': '', 'phone': '', 'location': ''},
  };
  bool _isDarkMode = false;
  bool _isLoading = true;
  String? _portfolioId;
  Timer? _autoSaveTimer;
  bool _isAutoSaving = false;
  bool _hasUnsavedChanges = false;
  
  @override
  void initState() {
    super.initState();
    _portfolioId = widget.portfolioId;
    if (_portfolioId != null) {
      _loadPortfolio();
    } else {
      _isLoading = false;
    }
  }
  
  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _titleController.dispose();
    _slugController.dispose();
    super.dispose();
  }
  
  void _triggerAutoSave() {
    _hasUnsavedChanges = true;
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(Duration(seconds: 3), () {
      if (_hasUnsavedChanges && _titleController.text.isNotEmpty && _slugController.text.isNotEmpty) {
        _autoSave();
      }
    });
  }
  
  Future<void> _autoSave() async {
    if (_isAutoSaving) return;
    
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.token == null || !authService.isAuthenticated) {
      return;
    }
    
    setState(() {
      _isAutoSaving = true;
    });
    
    try {
      final contentToSave = Map<String, dynamic>.from(_content);
      contentToSave['sections'] = _sections;
      
      if (_portfolioId != null) {
        await ApiService.put('/portfolios/$_portfolioId', {
          'title': _titleController.text,
          'slug': _slugController.text,
          'content': contentToSave,
        }, token: authService.token);
      } else {
        final response = await ApiService.post('/portfolios', {
          'title': _titleController.text,
          'slug': _slugController.text,
          'content': contentToSave,
        }, token: authService.token);
        
        if (mounted) {
          setState(() {
            _portfolioId = response['id'];
          });
        }
      }
      
      _hasUnsavedChanges = false;
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Auto-saved'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // Silently fail for auto-save - don't show error to user
      print('Auto-save failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isAutoSaving = false;
        });
      }
    }
  }
  
  Future<void> _loadPortfolio() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.token == null) {
        throw Exception('Not authenticated');
      }
      
      final portfolio = await ApiService.get('/portfolios/id/$_portfolioId', token: authService.token);
      
      setState(() {
        _titleController.text = portfolio['title'] ?? '';
        _slugController.text = portfolio['slug'] ?? '';
        _content = portfolio['content'] ?? _content;
        
        // Ensure experience and education sections exist in content if not present
        if (!_content.containsKey('experience')) {
          _content['experience'] = {'title': 'Experience', 'items': []};
        }
        if (!_content.containsKey('education')) {
          _content['education'] = {'title': 'Education', 'items': []};
        }
        
        _sections = (_content['sections'] as List?)?.map((e) => e.toString()).toList() ?? 
                    ['about', 'experience', 'education', 'projects', 'skills', 'contact'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load portfolio: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: LogoWidget(fontSize: 20, showTagline: false, color: Colors.white),
          backgroundColor: AppColors.primary,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: LogoWidget(fontSize: 20, showTagline: false, color: Colors.white),
        backgroundColor: AppColors.primary,
        actions: [
          if (_isAutoSaving)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _savePortfolio,
            tooltip: 'Save portfolio',
          ),
          SizedBox(width: 8),
          Tooltip(
            message: 'Publish portfolio',
            child: ElevatedButton.icon(
              onPressed: _publishPortfolio,
              icon: Icon(Icons.publish),
              label: Text('Publish', style: TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primary,
                elevation: 2,
              ),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Warning banner if not authenticated
          Consumer<AuthService>(
            builder: (context, authService, _) {
              if (!authService.isAuthenticated) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.orange.shade100,
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You need to log in to save your portfolio',
                          style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.w500),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/auth'),
                        child: Text('Login', style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 350,
                  color: AppColors.veryLightGray,
                  child: _buildEditorPanel(),
                ),
                Expanded(
                  child: Container(
                    color: _isDarkMode ? AppColors.dark : AppColors.white,
                    child: _buildPreview(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEditorPanel() {
    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        Text(
          'Portfolio Settings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.dark),
        ),
        SizedBox(height: 20),
        TextField(
          controller: _titleController,
          style: TextStyle(color: AppColors.dark),
          decoration: InputDecoration(
            labelText: 'Portfolio Title',
            labelStyle: TextStyle(color: AppColors.mediumGray),
            hintText: 'My Portfolio',
            hintStyle: TextStyle(color: AppColors.lightGray),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            filled: true,
            fillColor: AppColors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.lightGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onChanged: (v) {
            setState(() {});
            _triggerAutoSave();
          },
        ),
        SizedBox(height: 16),
        TextField(
          controller: _slugController,
          style: TextStyle(color: AppColors.dark),
          decoration: InputDecoration(
            labelText: 'URL Slug',
            labelStyle: TextStyle(color: AppColors.mediumGray),
            hintText: 'my-portfolio',
            hintStyle: TextStyle(color: AppColors.lightGray),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixText: 'elevare.com/p/',
            prefixStyle: TextStyle(color: AppColors.mediumGray),
            filled: true,
            fillColor: AppColors.white,
            helperText: 'Used in your portfolio URL',
            helperStyle: TextStyle(color: AppColors.mediumGray),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.lightGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onChanged: (v) {
            setState(() {});
            _triggerAutoSave();
          },
        ),
        SizedBox(height: 32),
        Text(
          'Sections',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.dark),
        ),
        SizedBox(height: 16),
        ReorderableListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: _sections.map((section) => _buildSectionItem(section)).toList(),
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex--;
              final item = _sections.removeAt(oldIndex);
              _sections.insert(newIndex, item);
            });
          },
        ),
        SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _addSection,
          icon: Icon(Icons.add, color: AppColors.primary),
          label: Text('Add Section', style: TextStyle(color: AppColors.primary)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.primary),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSectionItem(String section) {
    return Card(
      key: ValueKey(section),
      margin: EdgeInsets.only(bottom: 12),
      color: AppColors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(Icons.drag_indicator, color: AppColors.mediumGray),
        title: Text(section.toUpperCase(), style: TextStyle(color: AppColors.dark, fontWeight: FontWeight.w500)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, size: 20, color: AppColors.primary),
              onPressed: () => _editSection(section),
              tooltip: 'Edit section',
            ),
            IconButton(
              icon: Icon(Icons.delete, size: 20, color: AppColors.error),
              onPressed: () {
                setState(() {
                  _sections.remove(section);
                  _content.remove(section);
                });
              },
              tooltip: 'Delete section',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPreview() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titleController.text.isEmpty ? 'Your Portfolio Title' : _titleController.text,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _isDarkMode ? AppColors.white : AppColors.dark,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Professional Portfolio',
                    style: TextStyle(
                      fontSize: 20,
                      color: _isDarkMode ? AppColors.lightGray : AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
            ..._sections.map((section) => _buildPreviewSection(section)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPreviewSection(String section) {
    final sectionData = _content[section] ?? {};
    
    return Container(
      margin: EdgeInsets.only(bottom: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionData['title'] ?? section.toUpperCase(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? AppColors.white : AppColors.dark,
            ),
          ),
          SizedBox(height: 24),
          if (section == 'about')
            Text(
              sectionData['text'] ?? 'Tell visitors about yourself...',
              style: TextStyle(
                fontSize: 16,
                color: _isDarkMode ? AppColors.lightGray : AppColors.mediumGray,
                height: 1.6,
              ),
            )
          else if (section == 'experience')
            _buildExperiencePreview(sectionData)
          else if (section == 'education')
            _buildEducationPreview(sectionData)
          else if (section == 'projects')
            _buildProjectsPreview(sectionData)
          else if (section == 'skills')
            _buildSkillsPreview(sectionData)
          else if (section == 'contact')
            _buildContactPreview(sectionData)
          else
            Text(
              sectionData['text'] ?? 'Click edit to add content...',
              style: TextStyle(
                fontSize: 16,
                color: _isDarkMode ? AppColors.lightGray : AppColors.mediumGray,
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildProjectsPreview(Map<String, dynamic> data) {
    final projects = (data['items'] as List?) ?? [];
    if (projects.isEmpty) {
      return Text(
        'Click edit to add your projects...',
        style: TextStyle(
          fontSize: 16,
          color: _isDarkMode ? Colors.white70 : Colors.grey[700],
        ),
      );
    }
    
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: projects.map<Widget>((project) {
        return Container(
          width: 300,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project['name'] ?? 'Project',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? AppColors.white : AppColors.dark,
                ),
              ),
              SizedBox(height: 8),
              Text(
                project['description'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: _isDarkMode ? AppColors.lightGray : AppColors.mediumGray,
                ),
              ),
              if (project['url'] != null) ...[
                SizedBox(height: 8),
                Text(
                  project['url'],
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildExperiencePreview(Map<String, dynamic> data) {
    final experiences = (data['items'] as List?) ?? [];
    if (experiences.isEmpty) {
      return Text(
        'Click edit to add your experience...',
        style: TextStyle(
          fontSize: 16,
          color: _isDarkMode ? Colors.white70 : Colors.grey[700],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: experiences.map<Widget>((exp) {
        final company = exp['company'] ?? '';
        final position = exp['position'] ?? '';
        final startDate = exp['startDate'] ?? '';
        final endDate = exp['endDate'] ?? '';
        final location = exp['location'] ?? '';
        final description = exp['description'] ?? '';
        
        return Container(
          margin: EdgeInsets.only(bottom: 24),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
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
                    color: _isDarkMode ? AppColors.white : AppColors.dark,
                  ),
                ),
              if (company.isNotEmpty) ...[
                SizedBox(height: 4),
                Text(
                  company,
                  style: TextStyle(
                    fontSize: 16,
                    color: _isDarkMode ? AppColors.lightGray : AppColors.mediumGray,
                  ),
                ),
              ],
              if (startDate.isNotEmpty || endDate.isNotEmpty) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Color(0xFF667eea)),
                    SizedBox(width: 4),
                    Text(
                      endDate.isEmpty 
                          ? startDate 
                          : '$startDate - $endDate',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isDarkMode ? AppColors.lightGray : AppColors.mediumGray,
                      ),
                    ),
                    if (location.isNotEmpty) ...[
                      SizedBox(width: 16),
                      Icon(Icons.location_on, size: 14, color: Color(0xFF667eea)),
                      SizedBox(width: 4),
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 14,
                          color: _isDarkMode ? AppColors.lightGray : AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              if (description.isNotEmpty) ...[
                SizedBox(height: 12),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: _isDarkMode ? AppColors.lightGray : AppColors.mediumGray,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildSkillsPreview(Map<String, dynamic> data) {
    final skills = (data['items'] as List?) ?? [];
    if (skills.isEmpty) {
      return Text(
        'Click edit to add your skills...',
        style: TextStyle(
          fontSize: 16,
          color: _isDarkMode ? Colors.white70 : Colors.grey[700],
        ),
      );
    }
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: skills.map<Widget>((skill) {
        return Chip(
          label: Text(skill.toString()),
          backgroundColor: AppColors.primary,
          labelStyle: TextStyle(color: Colors.white),
          deleteIcon: Icon(Icons.close, size: 16, color: Colors.white70),
          onDeleted: () {
            setState(() {
              skills.remove(skill);
            });
          },
        );
      }).toList(),
    );
  }
  
  Widget _buildContactPreview(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data['email']?.isNotEmpty ?? false)
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.email, color: Color(0xFF667eea), size: 20),
                SizedBox(width: 12),
                Text(
                  data['email'],
                  style: TextStyle(
                    fontSize: 16,
                    color: _isDarkMode ? AppColors.lightGray : AppColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
        if (data['phone']?.isNotEmpty ?? false)
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.phone, color: Color(0xFF667eea), size: 20),
                SizedBox(width: 12),
                Text(
                  data['phone'],
                  style: TextStyle(
                    fontSize: 16,
                    color: _isDarkMode ? AppColors.lightGray : AppColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
        if (data['location']?.isNotEmpty ?? false)
          Row(
            children: [
              Icon(Icons.location_on, color: Color(0xFF667eea), size: 20),
              SizedBox(width: 12),
              Text(
                data['location'],
                style: TextStyle(
                  fontSize: 16,
                  color: _isDarkMode ? AppColors.lightGray : AppColors.mediumGray,
                ),
              ),
            ],
          ),
        if ((data['email']?.isEmpty ?? true) && 
            (data['phone']?.isEmpty ?? true) && 
            (data['location']?.isEmpty ?? true))
          Text(
            'Click edit to add contact information...',
            style: TextStyle(
              fontSize: 16,
              color: _isDarkMode ? AppColors.lightGray : AppColors.mediumGray,
            ),
          ),
      ],
    );
  }
  
  void _addSection() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('Add Section'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Section Name',
              hintText: 'e.g., Experience, Education',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  final sectionName = controller.text.toLowerCase().replaceAll(' ', '-');
                  setState(() {
                    _sections.add(sectionName);
                    _content[sectionName] = {
                      'title': controller.text,
                      'text': 'Add content here...'
                    };
                  });
                  _triggerAutoSave();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF667eea)),
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
  
  void _editSection(String section) {
    if (section == 'about') {
      _editAboutSection();
    } else if (section == 'experience') {
      _editExperienceSection();
    } else if (section == 'education') {
      _editEducationSection();
    } else if (section == 'projects') {
      _editProjectsSection();
    } else if (section == 'skills') {
      _editSkillsSection();
    } else if (section == 'contact') {
      _editContactSection();
    } else {
      _editCustomSection(section);
    }
  }
  
  void _editAboutSection() {
    final controller = TextEditingController(text: _content['about']['text']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit About Section'),
        content: Container(
          width: 500,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'About You',
              hintText: 'Tell visitors about yourself...',
              border: OutlineInputBorder(),
            ),
            maxLines: 8,
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _content['about']['text'] = controller.text;
              });
              _triggerAutoSave();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF667eea)),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _editExperienceSection() {
    final experiences = List<Map<String, String>>.from(
      (_content['experience']['items'] as List?)?.map((e) => Map<String, String>.from(e)) ?? []
    );
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Experience'),
          content: Container(
            width: 500,
            height: 400,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: experiences.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(experiences[index]['company'] ?? 'Experience ${index + 1}'),
                          subtitle: Text(experiences[index]['position'] ?? ''),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setDialogState(() {
                                experiences.removeAt(index);
                              });
                            },
                          ),
                          onTap: () {
                            _editExperience(experiences, index, setDialogState);
                          },
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setDialogState(() {
                      experiences.add({
                        'company': '',
                        'position': '',
                        'startDate': '',
                        'endDate': '',
                        'location': '',
                        'description': '',
                      });
                    });
                    _editExperience(experiences, experiences.length - 1, setDialogState);
                  },
                  icon: Icon(Icons.add),
                  label: Text('Add Experience'),
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF667eea)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _content['experience']['items'] = experiences;
                });
                _triggerAutoSave();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF667eea)),
              child: Text('Save All'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _editExperience(List<Map<String, String>> experiences, int index, StateSetter setDialogState) {
    final companyController = TextEditingController(text: experiences[index]['company']);
    final positionController = TextEditingController(text: experiences[index]['position']);
    final startDateController = TextEditingController(text: experiences[index]['startDate']);
    final endDateController = TextEditingController(text: experiences[index]['endDate'] ?? '');
    final locationController = TextEditingController(text: experiences[index]['location'] ?? '');
    final descriptionController = TextEditingController(text: experiences[index]['description'] ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Experience'),
        content: Container(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: companyController,
                  decoration: InputDecoration(
                    labelText: 'Company *',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: positionController,
                  decoration: InputDecoration(
                    labelText: 'Position/Title *',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: startDateController,
                  decoration: InputDecoration(
                    labelText: 'Start Date * (e.g., Jan 2020)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: endDateController,
                  decoration: InputDecoration(
                    labelText: 'End Date (e.g., Dec 2022 or "Present")',
                    border: OutlineInputBorder(),
                    helperText: 'Leave empty if current position',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setDialogState(() {
                experiences[index] = {
                  'company': companyController.text,
                  'position': positionController.text,
                  'startDate': startDateController.text,
                  'endDate': endDateController.text,
                  'location': locationController.text,
                  'description': descriptionController.text,
                };
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF667eea)),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _editEducationSection() {
    final educations = List<Map<String, String>>.from(
      (_content['education']['items'] as List?)?.map((e) => Map<String, String>.from(e)) ?? []
    );
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Education'),
          content: Container(
            width: 500,
            height: 400,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: educations.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(educations[index]['degree'] ?? 'Education ${index + 1}'),
                          subtitle: Text(educations[index]['institution'] ?? ''),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setDialogState(() {
                                educations.removeAt(index);
                              });
                            },
                          ),
                          onTap: () {
                            _editEducation(educations, index, setDialogState);
                          },
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setDialogState(() {
                      educations.add({
                        'institution': '',
                        'degree': '',
                        'field': '',
                        'startDate': '',
                        'endDate': '',
                        'location': '',
                        'description': '',
                      });
                    });
                    _editEducation(educations, educations.length - 1, setDialogState);
                  },
                  icon: Icon(Icons.add),
                  label: Text('Add Education'),
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF667eea)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _content['education']['items'] = educations;
                });
                _triggerAutoSave();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF667eea)),
              child: Text('Save All'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _editEducation(List<Map<String, String>> educations, int index, StateSetter setDialogState) {
    final institutionController = TextEditingController(text: educations[index]['institution']);
    final degreeController = TextEditingController(text: educations[index]['degree']);
    final fieldController = TextEditingController(text: educations[index]['field'] ?? '');
    final startDateController = TextEditingController(text: educations[index]['startDate']);
    final endDateController = TextEditingController(text: educations[index]['endDate'] ?? '');
    final locationController = TextEditingController(text: educations[index]['location'] ?? '');
    final descriptionController = TextEditingController(text: educations[index]['description'] ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Education'),
        content: Container(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: institutionController,
                  decoration: InputDecoration(
                    labelText: 'Institution *',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: degreeController,
                  decoration: InputDecoration(
                    labelText: 'Degree * (e.g., Bachelor of Science)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: fieldController,
                  decoration: InputDecoration(
                    labelText: 'Field of Study (e.g., Computer Science)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: startDateController,
                  decoration: InputDecoration(
                    labelText: 'Start Date * (e.g., 2018)',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: endDateController,
                  decoration: InputDecoration(
                    labelText: 'End Date (e.g., 2022 or "Present")',
                    border: OutlineInputBorder(),
                    helperText: 'Leave empty if current',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (e.g., GPA, Honors, Relevant Coursework)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setDialogState(() {
                educations[index] = {
                  'institution': institutionController.text,
                  'degree': degreeController.text,
                  'field': fieldController.text,
                  'startDate': startDateController.text,
                  'endDate': endDateController.text,
                  'location': locationController.text,
                  'description': descriptionController.text,
                };
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF667eea)),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEducationPreview(Map<String, dynamic> data) {
    final educations = (data['items'] as List?) ?? [];
    if (educations.isEmpty) {
      return Text(
        'Click edit to add your education...',
        style: TextStyle(
          fontSize: 16,
          color: _isDarkMode ? Colors.white70 : Colors.grey[700],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: educations.map<Widget>((edu) {
        final institution = edu['institution'] ?? '';
        final degree = edu['degree'] ?? '';
        final field = edu['field'] ?? '';
        final startDate = edu['startDate'] ?? '';
        final endDate = edu['endDate'] ?? '';
        final location = edu['location'] ?? '';
        final description = edu['description'] ?? '';
        
        return Container(
          margin: EdgeInsets.only(bottom: 24),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (degree.isNotEmpty)
                Text(
                  degree,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? AppColors.white : AppColors.dark,
                  ),
                ),
              if (field.isNotEmpty) ...[
                SizedBox(height: 4),
                Text(
                  field,
                  style: TextStyle(
                    fontSize: 16,
                    color: _isDarkMode ? AppColors.lightGray : AppColors.mediumGray,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              if (institution.isNotEmpty) ...[
                SizedBox(height: 4),
                Text(
                  institution,
                  style: TextStyle(
                    fontSize: 16,
                    color: _isDarkMode ? AppColors.lightGray : AppColors.mediumGray,
                  ),
                ),
              ],
              if (startDate.isNotEmpty || endDate.isNotEmpty) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Color(0xFF667eea)),
                    SizedBox(width: 4),
                    Text(
                      endDate.isEmpty 
                          ? startDate 
                          : '$startDate - $endDate',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isDarkMode ? AppColors.lightGray : AppColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ],
              if (location.isNotEmpty) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Color(0xFF667eea)),
                    SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 14,
                        color: _isDarkMode ? AppColors.lightGray : AppColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ],
              if (description.isNotEmpty) ...[
                SizedBox(height: 12),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: _isDarkMode ? AppColors.lightGray : AppColors.mediumGray,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
  
  void _editProjectsSection() {
    final projects = List<Map<String, String>>.from(
      (_content['projects']['items'] as List?)?.map((p) => Map<String, String>.from(p)) ?? []
    );
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Projects'),
          content: Container(
            width: 500,
            height: 400,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(projects[index]['name'] ?? 'Project ${index + 1}'),
                          subtitle: Text(projects[index]['description'] ?? ''),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setDialogState(() {
                                projects.removeAt(index);
                              });
                            },
                          ),
                          onTap: () {
                            _editProject(projects, index, setDialogState);
                          },
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setDialogState(() {
                      projects.add({'name': '', 'description': '', 'url': ''});
                    });
                    _editProject(projects, projects.length - 1, setDialogState);
                  },
                  icon: Icon(Icons.add),
                  label: Text('Add Project'),
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF667eea)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _content['projects']['items'] = projects;
                });
                _triggerAutoSave();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF667eea)),
              child: Text('Save All'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _editProject(List<Map<String, String>> projects, int index, StateSetter setDialogState) {
    final nameController = TextEditingController(text: projects[index]['name']);
    final descController = TextEditingController(text: projects[index]['description']);
    final urlController = TextEditingController(text: projects[index]['url']);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Project'),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Project Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: 'Project URL (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setDialogState(() {
                projects[index] = {
                  'name': nameController.text,
                  'description': descController.text,
                  'url': urlController.text,
                };
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF667eea)),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _editSkillsSection() {
    final skills = List<String>.from((_content['skills']['items'] as List?) ?? []);
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Skills'),
          content: Container(
            width: 400,
            height: 400,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Add Skill',
                          hintText: 'e.g., Flutter, Dart',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            setDialogState(() {
                              skills.add(value);
                              controller.clear();
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          setDialogState(() {
                            skills.add(controller.text);
                            controller.clear();
                          });
                        }
                      },
                      color: AppColors.primary,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: skills.map((skill) {
                      return Chip(
                        label: Text(skill),
                        deleteIcon: Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setDialogState(() {
                            skills.remove(skill);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _content['skills']['items'] = skills;
                });
                _triggerAutoSave();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF667eea)),
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _editContactSection() {
    final emailController = TextEditingController(text: _content['contact']['email']);
    final phoneController = TextEditingController(text: _content['contact']['phone']);
    final locationController = TextEditingController(text: _content['contact']['location']);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Contact Information'),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _content['contact']['email'] = emailController.text;
                _content['contact']['phone'] = phoneController.text;
                _content['contact']['location'] = locationController.text;
              });
              _triggerAutoSave();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF667eea)),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _editCustomSection(String section) {
    final controller = TextEditingController(text: _content[section]['text']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${_content[section]['title']}'),
        content: Container(
          width: 500,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Content',
              border: OutlineInputBorder(),
            ),
            maxLines: 8,
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _content[section]['text'] = controller.text;
              });
              _triggerAutoSave();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF667eea)),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
  
  Future<bool?> _savePortfolio() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add a portfolio title')),
      );
      return false;
    }
    
    if (_slugController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add a URL slug')),
      );
      return false;
    }
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Check if user is authenticated
      if (authService.token == null || !authService.isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please log in to save your portfolio'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Login',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/auth');
              },
            ),
          ),
        );
        return false;
      }
      
      final contentToSave = Map<String, dynamic>.from(_content);
      contentToSave['sections'] = _sections;
      
      Map<String, dynamic> response;
      if (_portfolioId != null) {
        // Update existing portfolio
        response = await ApiService.put('/portfolios/$_portfolioId', {
          'title': _titleController.text,
          'slug': _slugController.text,
          'content': contentToSave,
        }, token: authService.token);
      } else {
        // Create new portfolio
        response = await ApiService.post('/portfolios', {
          'title': _titleController.text,
          'slug': _slugController.text,
          'content': contentToSave,
        }, token: authService.token);
        
        setState(() {
          _portfolioId = response['id'];
        });
      }
      
      _hasUnsavedChanges = false;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_portfolioId != null ? 'Portfolio updated successfully!' : 'Portfolio saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Return true to indicate successful save (for dashboard refresh)
      return true;
    } catch (e) {
      String errorMessage = 'Failed to save portfolio';
      if (e.toString().contains('Unauthorized') || e.toString().contains('401')) {
        errorMessage = 'Please log in to save your portfolio';
        // Optionally redirect to login
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/auth');
          }
        });
      } else if (e.toString().contains('403')) {
        errorMessage = 'You do not have permission to save this portfolio';
      } else if (e.toString().contains('400')) {
        errorMessage = 'Invalid portfolio data. Please check your inputs.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return false;
    }
  }
  
  Future<void> _publishPortfolio() async {
    if (_portfolioId == null) {
      final saved = await _savePortfolio();
      if (saved != true || _portfolioId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please save the portfolio before publishing'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }
    
    if (_slugController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add a URL slug before publishing')),
      );
      return;
    }
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      if (authService.token == null || !authService.isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please log in to publish your portfolio'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Login',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/auth');
              },
            ),
          ),
        );
        return;
      }
      
      await ApiService.post('/portfolios/$_portfolioId/publish', {}, token: authService.token);
      
      // Show success message briefly, then redirect
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Portfolio published successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Wait a moment for the snackbar to show, then redirect
      await Future.delayed(Duration(milliseconds: 500));
      
      if (mounted) {
        // Navigate to the published portfolio page
        Navigator.pushNamed(context, '/p/${_slugController.text}').then((_) {
          // After viewing, go back to dashboard
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        });
      }
    } catch (e) {
      String errorMessage = 'Failed to publish portfolio';
      if (e.toString().contains('Unauthorized') || e.toString().contains('401')) {
        errorMessage = 'Please log in to publish your portfolio';
      } else if (e.toString().contains('403') || e.toString().contains('Access denied')) {
        errorMessage = 'You do not have permission to publish this portfolio';
      } else if (e.toString().contains('404') || e.toString().contains('not found')) {
        errorMessage = 'Portfolio not found. Please save it first.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }
}