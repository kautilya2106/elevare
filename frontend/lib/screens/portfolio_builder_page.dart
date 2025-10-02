// lib/screens/portfolio_builder_page.dart - FULLY FUNCTIONAL VERSION
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class PortfolioBuilderPage extends StatefulWidget {
  @override
  _PortfolioBuilderPageState createState() => _PortfolioBuilderPageState();
}

class _PortfolioBuilderPageState extends State<PortfolioBuilderPage> {
  final _titleController = TextEditingController();
  final _slugController = TextEditingController();
  List<String> _sections = ['about', 'projects', 'skills', 'contact'];
  Map<String, dynamic> _content = {
    'about': {'title': 'About Me', 'text': 'I am a passionate developer...'},
    'projects': {'title': 'Projects', 'items': []},
    'skills': {'title': 'Skills', 'items': []},
    'contact': {'title': 'Contact', 'email': '', 'phone': '', 'location': ''},
  };
  bool _isDarkMode = false;
  String? _portfolioId;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Portfolio Builder'),
        backgroundColor: Color(0xFF667eea),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _savePortfolio,
            tooltip: 'Save Draft',
          ),
          SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _publishPortfolio,
            icon: Icon(Icons.publish),
            label: Text('Publish'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF667eea),
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 350,
            color: Colors.grey[100],
            child: _buildEditorPanel(),
          ),
          Expanded(
            child: Container(
              color: _isDarkMode ? Colors.grey[900] : Colors.white,
              child: _buildPreview(),
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Portfolio Title',
            hintText: 'My Portfolio',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (v) => setState(() {}),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _slugController,
          decoration: InputDecoration(
            labelText: 'URL Slug',
            hintText: 'my-portfolio',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixText: 'elevare.com/p/',
          ),
          onChanged: (v) => setState(() {}),
        ),
        SizedBox(height: 32),
        Text(
          'Sections',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          icon: Icon(Icons.add),
          label: Text('Add Section'),
        ),
      ],
    );
  }
  
  Widget _buildSectionItem(String section) {
    return Card(
      key: ValueKey(section),
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.drag_indicator),
        title: Text(section.toUpperCase()),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, size: 20),
              onPressed: () => _editSection(section),
            ),
            IconButton(
              icon: Icon(Icons.delete, size: 20),
              onPressed: () {
                setState(() {
                  _sections.remove(section);
                  _content.remove(section);
                });
              },
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
                      color: _isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Professional Portfolio',
                    style: TextStyle(
                      fontSize: 20,
                      color: _isDarkMode ? Colors.white70 : Colors.grey[600],
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
              color: _isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 24),
          if (section == 'about')
            Text(
              sectionData['text'] ?? 'Tell visitors about yourself...',
              style: TextStyle(
                fontSize: 16,
                color: _isDarkMode ? Colors.white70 : Colors.grey[700],
                height: 1.6,
              ),
            )
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
                color: _isDarkMode ? Colors.white70 : Colors.grey[700],
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
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                project['description'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: _isDarkMode ? Colors.white70 : Colors.grey[700],
                ),
              ),
              if (project['url'] != null) ...[
                SizedBox(height: 8),
                Text(
                  project['url'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF667eea),
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
          backgroundColor: Color(0xFF667eea),
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
                    color: _isDarkMode ? Colors.white70 : Colors.grey[700],
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
                    color: _isDarkMode ? Colors.white70 : Colors.grey[700],
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
                  color: _isDarkMode ? Colors.white70 : Colors.grey[700],
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
              color: _isDarkMode ? Colors.white70 : Colors.grey[700],
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
                      color: Color(0xFF667eea),
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
  
  Future<void> _savePortfolio() async {
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
      final response = await ApiService.post('/portfolios', {
        'title': _titleController.text,
        'slug': _slugController.text,
        'content': _content,
      });
      
      setState(() {
        _portfolioId = response['id'];
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Portfolio saved successfully!'),
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
    if (_portfolioId == null) {
      await _savePortfolio();
      if (_portfolioId == null) return;
    }
    
    try {
      await ApiService.post('/portfolios/$_portfolioId/publish', {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Portfolio published! View at: elevare.com/p/${_slugController.text}'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/p/${_slugController.text}');
            },
          ),
        ),
      );
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