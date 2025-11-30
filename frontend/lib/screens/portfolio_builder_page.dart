// lib/screens/portfolio_builder_page.dart - FULLY FUNCTIONAL VERSION
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../widgets/logo_widget.dart';
import '../theme/app_colors.dart';

class PortfolioBuilderPage extends StatefulWidget {
  final String? portfolioId;
  final String? templateId;
  
  PortfolioBuilderPage({this.portfolioId, this.templateId});
  
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
  
  @override
  void initState() {
    super.initState();
    _portfolioId = widget.portfolioId;
    if (widget.templateId != null) {
      _loadTemplate();
    } else if (_portfolioId != null) {
      _loadPortfolio();
    } else {
      _isLoading = false;
    }
  }
  
  Future<void> _loadTemplate() async {
    try {
      final template = await ApiService.get('/templates/${widget.templateId}');
      
      setState(() {
        if (template['content'] != null) {
          final templateContent = Map<String, dynamic>.from(template['content']);
          
          // Check if sections is an array of objects (new format) or strings (old format)
          final sectionsList = templateContent['sections'] as List?;
          
          if (sectionsList != null && sectionsList.isNotEmpty) {
            // Check if first element is a Map (new format with objects)
            if (sectionsList.first is Map) {
              // Transform from new format (array of objects) to old format (map with string keys)
              _content = {};
              _sections = [];
              
              for (var sectionObj in sectionsList) {
                if (sectionObj is Map) {
                  final sectionType = (sectionObj['type'] ?? sectionObj['TYPE'] ?? '').toString().toLowerCase();
                  if (sectionType.isNotEmpty) {
                    // Map section types to our section names
                    String sectionName;
                    switch (sectionType) {
                      case 'hero':
                        // Skip hero sections, they're not supported in our builder
                        continue;
                      case 'about':
                        sectionName = 'about';
                        _content[sectionName] = {
                          'title': sectionObj['title'] ?? sectionObj['TITLE'] ?? 'About Me',
                          'text': sectionObj['content'] ?? sectionObj['CONTENT'] ?? sectionObj['text'] ?? sectionObj['TEXT'] ?? 'Tell your story...',
                        };
                        break;
                      case 'experience':
                        sectionName = 'experience';
                        _content[sectionName] = {
                          'title': sectionObj['title'] ?? sectionObj['TITLE'] ?? 'Experience',
                          'items': sectionObj['items'] ?? sectionObj['ITEMS'] ?? [],
                        };
                        break;
                      case 'education':
                        sectionName = 'education';
                        _content[sectionName] = {
                          'title': sectionObj['title'] ?? sectionObj['TITLE'] ?? 'Education',
                          'items': sectionObj['items'] ?? sectionObj['ITEMS'] ?? [],
                        };
                        break;
                      case 'projects':
                        sectionName = 'projects';
                        _content[sectionName] = {
                          'title': sectionObj['title'] ?? sectionObj['TITLE'] ?? 'Projects',
                          'items': sectionObj['items'] ?? sectionObj['ITEMS'] ?? [],
                        };
                        break;
                      case 'skills':
                        sectionName = 'skills';
                        _content[sectionName] = {
                          'title': sectionObj['title'] ?? sectionObj['TITLE'] ?? 'Skills',
                          'items': sectionObj['items'] ?? sectionObj['ITEMS'] ?? [],
                        };
                        break;
                      case 'contact':
                        sectionName = 'contact';
                        _content[sectionName] = {
                          'title': sectionObj['title'] ?? sectionObj['TITLE'] ?? 'Contact',
                          'email': sectionObj['email'] ?? sectionObj['EMAIL'] ?? '',
                          'phone': sectionObj['phone'] ?? sectionObj['PHONE'] ?? '',
                          'location': sectionObj['location'] ?? sectionObj['LOCATION'] ?? '',
                        };
                        break;
                      default:
                        continue; // Skip unknown section types
                    }
                    _sections.add(sectionName);
                  }
                }
              }
            } else {
              // Old format: sections is array of strings
              _content = Map<String, dynamic>.from(templateContent);
              _sections = sectionsList.map((e) => e.toString()).toList();
            }
          } else {
            // No sections, use defaults
            _content = Map<String, dynamic>.from(templateContent);
            _sections = ['about', 'experience', 'education', 'projects', 'skills', 'contact'];
          }
          
          // Ensure all standard sections exist and have proper structure
          final standardSections = ['about', 'experience', 'education', 'projects', 'skills', 'contact'];
          
          // First, ensure all sections from template have proper structure
          for (var sectionName in _sections) {
            if (sectionName == 'experience' || sectionName == 'education' || sectionName == 'projects' || sectionName == 'skills') {
              if (_content[sectionName] is Map && !(_content[sectionName] as Map).containsKey('items')) {
                (_content[sectionName] as Map)['items'] = [];
              }
            }
          }
          
          // Then, add any missing standard sections
          for (var sectionName in standardSections) {
            if (!_content.containsKey(sectionName) || _content[sectionName] == null) {
              // Add missing section with default structure
              switch (sectionName) {
                case 'about':
                  _content[sectionName] = {'title': 'About Me', 'text': 'I am a passionate developer...'};
                  break;
                case 'experience':
                  _content[sectionName] = {'title': 'Experience', 'items': []};
                  break;
                case 'education':
                  _content[sectionName] = {'title': 'Education', 'items': []};
                  break;
                case 'projects':
                  _content[sectionName] = {'title': 'Projects', 'items': []};
                  break;
                case 'skills':
                  _content[sectionName] = {'title': 'Skills', 'items': []};
                  break;
                case 'contact':
                  _content[sectionName] = {'title': 'Contact', 'email': '', 'phone': '', 'location': ''};
                  break;
              }
            }
            // Add to sections list if not already there (maintain template order, append missing ones)
            if (!_sections.contains(sectionName)) {
              _sections.add(sectionName);
            }
          }
        } else {
          // If no content, use defaults
          _sections = ['about', 'experience', 'education', 'projects', 'skills', 'contact'];
        }
        _titleController.text = template['name'] ?? 'New Portfolio';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load template: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
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
        
        // Ensure all standard sections exist in content
        final standardSections = ['about', 'experience', 'education', 'projects', 'skills', 'contact'];
        
        for (var sectionName in standardSections) {
          if (!_content.containsKey(sectionName) || _content[sectionName] == null) {
            switch (sectionName) {
              case 'about':
                _content[sectionName] = {'title': 'About Me', 'text': 'I am a passionate developer...'};
                break;
              case 'experience':
                _content[sectionName] = {'title': 'Experience', 'items': []};
                break;
              case 'education':
                _content[sectionName] = {'title': 'Education', 'items': []};
                break;
              case 'projects':
                _content[sectionName] = {'title': 'Projects', 'items': []};
                break;
              case 'skills':
                _content[sectionName] = {'title': 'Skills', 'items': []};
                break;
              case 'contact':
                _content[sectionName] = {'title': 'Contact', 'email': '', 'phone': '', 'location': ''};
                break;
            }
          }
        }
        
        // Load sections from content, but ensure all standard sections are included
        final loadedSections = (_content['sections'] as List?)?.map((e) => e.toString()).toList() ?? [];
        _sections = [];
        
        // Add sections from loaded content first (preserve order)
        for (var section in loadedSections) {
          if (standardSections.contains(section) && !_sections.contains(section)) {
            _sections.add(section);
          }
        }
        
        // Add any missing standard sections
        for (var section in standardSections) {
          if (!_sections.contains(section)) {
            _sections.add(section);
          }
        }
        
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
      body: Row(
        children: [
          Container(
            width: 350,
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
    );
  }
  
  Widget _buildEditorPanel() {
    final isDark = _isDarkMode;
    final backgroundColor = isDark ? AppColors.darkGray : AppColors.veryLightGray;
    final textColor = isDark ? AppColors.white : AppColors.dark;
    final secondaryTextColor = isDark ? AppColors.lightGray : AppColors.mediumGray;
    final mutedTextColor = isDark ? AppColors.mediumGray : AppColors.lightGray;
    final inputFillColor = isDark ? AppColors.dark : AppColors.white;
    
    return Container(
      color: backgroundColor,
      child: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Text(
            'Portfolio Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _titleController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'Portfolio Title',
              labelStyle: TextStyle(color: secondaryTextColor),
              hintText: 'My Portfolio',
              hintStyle: TextStyle(color: mutedTextColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: inputFillColor,
            ),
            onChanged: (v) => setState(() {}),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _slugController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'URL Slug',
              labelStyle: TextStyle(color: secondaryTextColor),
              hintText: 'my-portfolio',
              hintStyle: TextStyle(color: mutedTextColor),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixText: 'elevare.com/p/',
              prefixStyle: TextStyle(color: secondaryTextColor),
              filled: true,
              fillColor: inputFillColor,
              helperText: 'Used in your portfolio URL',
              helperStyle: TextStyle(color: mutedTextColor),
            ),
            onChanged: (v) => setState(() {}),
          ),
        SizedBox(height: 32),
        Text(
          'Sections',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
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
      ),
    );
  }
  
  Widget _buildSectionItem(String section) {
    final isDark = _isDarkMode;
    final cardColor = isDark ? AppColors.dark : AppColors.white;
    final textColor = isDark ? AppColors.white : AppColors.dark;
    final iconColor = isDark ? AppColors.lightGray : AppColors.mediumGray;
    
    return Card(
      key: ValueKey(section),
      margin: EdgeInsets.only(bottom: 12),
      color: cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(Icons.drag_indicator, color: iconColor),
        title: Text(section.toUpperCase(), style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
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
    final sectionDataRaw = _content[section];
    
    // Handle null or invalid section data
    if (sectionDataRaw == null || sectionDataRaw is! Map) {
      return Container(
        margin: EdgeInsets.only(bottom: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.toUpperCase(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _isDarkMode ? AppColors.white : AppColors.dark,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Click edit to add content...',
              style: TextStyle(
                fontSize: 16,
                color: _isDarkMode ? AppColors.lightGray : AppColors.mediumGray,
              ),
            ),
          ],
        ),
      );
    }
    
    // Cast to proper type
    final sectionData = Map<String, dynamic>.from(sectionDataRaw);
    
    return Container(
      margin: EdgeInsets.only(bottom: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (sectionData['title'] ?? sectionData['TITLE'] ?? section.toUpperCase()).toString(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? AppColors.white : AppColors.dark,
            ),
          ),
          SizedBox(height: 24),
          if (section == 'about')
            Text(
              (sectionData['text'] ?? sectionData['TEXT'] ?? sectionData['CONTENT'] ?? 'Tell visitors about yourself...').toString(),
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
              (sectionData['text'] ?? sectionData['TEXT'] ?? sectionData['CONTENT'] ?? 'Click edit to add content...').toString(),
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
        final degree = edu['degree'] ?? '';
        final institution = edu['institution'] ?? '';
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
                          title: Text(educations[index]['institution'] ?? 'Education ${index + 1}'),
                          subtitle: Text(educations[index]['degree'] ?? ''),
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
                        'degree': '',
                        'institution': '',
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
    final degreeController = TextEditingController(text: educations[index]['degree']);
    final institutionController = TextEditingController(text: educations[index]['institution']);
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
                    labelText: 'Degree/Certification *',
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
                educations[index] = {
                  'degree': degreeController.text,
                  'institution': institutionController.text,
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
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF667eea)),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
  
  Future<bool> _checkAuthentication() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.token == null || !authService.isAuthenticated) {
      final shouldLogin = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login Required'),
          content: Text('You need to login or register to save and publish your portfolio. Would you like to login now?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text('Login / Register'),
            ),
          ],
        ),
      );
      
      if (shouldLogin == true) {
        // Navigate to auth page with current route as argument so we can return
        await Navigator.pushNamed(
          context, 
          '/auth',
          arguments: {'returnRoute': '/builder', 'returnArgs': widget.templateId != null ? {'templateId': widget.templateId} : (widget.portfolioId != null ? {'portfolioId': widget.portfolioId} : null)},
        );
        // Check again after returning from auth page
        final authServiceAfter = Provider.of<AuthService>(context, listen: false);
        if (authServiceAfter.isAuthenticated) {
          // If we had a template, reload it with the new auth
          if (widget.templateId != null) {
            await _loadTemplate();
          }
          return true;
        }
        return false;
      }
      return false;
    }
    return true;
  }
  
  Future<void> _savePortfolio() async {
    // Check authentication first
    if (!await _checkAuthentication()) {
      return;
    }
    
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add a portfolio title')),
      );
      return;
    }
    
    if (_slugController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add a URL slug')),
      );
      return;
    }
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
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
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_portfolioId != null ? 'Portfolio updated successfully!' : 'Portfolio saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _publishPortfolio() async {
    // Check authentication first
    if (!await _checkAuthentication()) {
      return;
    }
    
    if (_portfolioId == null) {
      await _savePortfolio();
      if (_portfolioId == null) return;
    }
    
    if (_slugController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add a URL slug before publishing')),
      );
      return;
    }
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
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
      
      // Navigate to the published portfolio page
      Navigator.pushReplacementNamed(context, '/p/${_slugController.text}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to publish: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}