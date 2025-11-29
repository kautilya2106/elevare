// backend/bin/server.dart
import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

// Configuration
class Config {
  static final String dbHost = Platform.environment['DB_HOST'] ?? 'localhost';
  static final int dbPort = int.parse(Platform.environment['DB_PORT'] ?? '5432');
  static final String dbName = Platform.environment['DB_NAME'] ?? 'elevare';
  static final String dbUser = Platform.environment['DB_USER'] ?? 'postgres';
  static final String dbPassword = Platform.environment['DB_PASSWORD'] ?? 'changeme';
  static final String jwtSecret = Platform.environment['JWT_SECRET'] ?? 'your-secret-key-change-in-production';
  static final int port = int.parse(Platform.environment['PORT'] ?? '8080');
}

// Database Connection
class Database {
  static Connection? _connection;
  
  static Future<Connection> get connection async {
    if (_connection == null) {
      _connection = await Connection.open(
        Endpoint(
          host: Config.dbHost,
          port: Config.dbPort,
          database: Config.dbName,
          username: Config.dbUser,
          password: Config.dbPassword,
        ),
        settings: ConnectionSettings(sslMode: SslMode.disable),
      );
      await _initTables();
    }
    return _connection!;
  }
  
  static Future<void> _initTables() async {
    await _connection!.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        username VARCHAR(100) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        full_name VARCHAR(255),
        avatar_url TEXT,
        role VARCHAR(50) DEFAULT 'user',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    await _connection!.execute('''
      CREATE TABLE IF NOT EXISTS portfolios (
        id UUID PRIMARY KEY,
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        title VARCHAR(255) NOT NULL,
        slug VARCHAR(255) UNIQUE NOT NULL,
        template_id UUID,
        content JSONB NOT NULL,
        is_published BOOLEAN DEFAULT false,
        theme VARCHAR(50) DEFAULT 'light',
        custom_domain VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    await _connection!.execute('''
      CREATE TABLE IF NOT EXISTS templates (
        id UUID PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        thumbnail_url TEXT,
        category VARCHAR(100),
        content JSONB NOT NULL,
        is_featured BOOLEAN DEFAULT false,
        is_approved BOOLEAN DEFAULT false,
        created_by UUID REFERENCES users(id),
        downloads INT DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    await _connection!.execute('''
      CREATE TABLE IF NOT EXISTS analytics (
        id UUID PRIMARY KEY,
        portfolio_id UUID REFERENCES portfolios(id) ON DELETE CASCADE,
        event_type VARCHAR(50) NOT NULL,
        referrer TEXT,
        ip_address VARCHAR(45),
        user_agent TEXT,
        metadata JSONB,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
      await _connection!.execute('''
      CREATE INDEX IF NOT EXISTS idx_analytics_portfolio ON analytics(portfolio_id, created_at)
    ''');
    
    await _seedTemplates();
  }
  
  static Future<void> _seedTemplates() async {
    // Check if templates already exist
    final checkResult = await _connection!.execute('SELECT COUNT(*) as count FROM templates');
    final count = checkResult.first.toColumnMap()['count'] as int;
    if (count > 0) {
      return; // Templates already seeded
    }
    
    final templates = [
      {
        'id': Uuid().v4(),
        'name': 'Modern Minimal',
        'description': 'Clean and contemporary design with plenty of white space. Perfect for showcasing your work with elegance.',
        'category': 'Minimal',
        'is_featured': true,
        'downloads': 1250,
        'content': json.encode({
          'sections': ['about', 'projects', 'skills', 'contact'],
          'about': {'title': 'About Me', 'text': 'I am a passionate developer and designer...'},
          'projects': {'title': 'Projects', 'items': []},
          'skills': {'title': 'Skills', 'items': []},
          'contact': {'title': 'Contact', 'email': '', 'phone': '', 'location': ''},
        }),
      },
      {
        'id': Uuid().v4(),
        'name': 'Creative Portfolio',
        'description': 'Bold and vibrant template for creative professionals. Stand out with colorful sections and dynamic layouts.',
        'category': 'Creative',
        'is_featured': true,
        'downloads': 980,
        'content': json.encode({
          'sections': ['about', 'projects', 'skills', 'experience', 'contact'],
          'about': {'title': 'About Me', 'text': 'Creative professional with a passion for innovation...'},
          'projects': {'title': 'Featured Work', 'items': []},
          'skills': {'title': 'Expertise', 'items': []},
          'experience': {'title': 'Experience', 'text': 'Add your professional experience here...'},
          'contact': {'title': 'Get In Touch', 'email': '', 'phone': '', 'location': ''},
        }),
      },
      {
        'id': Uuid().v4(),
        'name': 'Professional Classic',
        'description': 'Timeless professional template ideal for business professionals and consultants.',
        'category': 'Professional',
        'is_featured': false,
        'downloads': 750,
        'content': json.encode({
          'sections': ['about', 'experience', 'education', 'skills', 'contact'],
          'about': {'title': 'About', 'text': 'Experienced professional with a proven track record...'},
          'experience': {'title': 'Professional Experience', 'text': 'Add your work history here...'},
          'education': {'title': 'Education', 'text': 'List your educational background...'},
          'skills': {'title': 'Core Competencies', 'items': []},
          'contact': {'title': 'Contact Information', 'email': '', 'phone': '', 'location': ''},
        }),
      },
      {
        'id': Uuid().v4(),
        'name': 'Tech Innovator',
        'description': 'Modern tech-focused template with sleek design. Perfect for developers and tech entrepreneurs.',
        'category': 'Modern',
        'is_featured': true,
        'downloads': 1100,
        'content': json.encode({
          'sections': ['about', 'projects', 'skills', 'blog', 'contact'],
          'about': {'title': 'About', 'text': 'Tech enthusiast and problem solver...'},
          'projects': {'title': 'Projects & Products', 'items': []},
          'skills': {'title': 'Technologies', 'items': []},
          'blog': {'title': 'Latest Articles', 'text': 'Share your thoughts and insights...'},
          'contact': {'title': 'Connect', 'email': '', 'phone': '', 'location': ''},
        }),
      },
      {
        'id': Uuid().v4(),
        'name': 'Artist Showcase',
        'description': 'Beautiful template designed for artists, photographers, and visual creators.',
        'category': 'Creative',
        'is_featured': false,
        'downloads': 650,
        'content': json.encode({
          'sections': ['about', 'gallery', 'exhibitions', 'contact'],
          'about': {'title': 'About the Artist', 'text': 'Passionate about creating visual stories...'},
          'gallery': {'title': 'Portfolio Gallery', 'items': []},
          'exhibitions': {'title': 'Exhibitions & Shows', 'text': 'List your exhibitions and shows...'},
          'contact': {'title': 'Commission Inquiry', 'email': '', 'phone': '', 'location': ''},
        }),
      },
      {
        'id': Uuid().v4(),
        'name': 'Startup Founder',
        'description': 'Dynamic template for entrepreneurs and startup founders to showcase their journey.',
        'category': 'Modern',
        'is_featured': false,
        'downloads': 520,
        'content': json.encode({
          'sections': ['about', 'startup', 'achievements', 'contact'],
          'about': {'title': 'Founder Story', 'text': 'Building the future, one idea at a time...'},
          'startup': {'title': 'The Startup', 'text': 'Tell your startup story...'},
          'achievements': {'title': 'Milestones', 'items': []},
          'contact': {'title': 'Let\'s Connect', 'email': '', 'phone': '', 'location': ''},
        }),
      },
      {
        'id': Uuid().v4(),
        'name': 'Academic Scholar',
        'description': 'Clean and structured template perfect for researchers, academics, and scholars.',
        'category': 'Professional',
        'is_featured': false,
        'downloads': 430,
        'content': json.encode({
          'sections': ['about', 'research', 'publications', 'education', 'contact'],
          'about': {'title': 'About', 'text': 'Researcher and academic with expertise in...'},
          'research': {'title': 'Research Interests', 'text': 'Describe your research focus...'},
          'publications': {'title': 'Publications', 'items': []},
          'education': {'title': 'Education', 'text': 'Academic qualifications...'},
          'contact': {'title': 'Contact', 'email': '', 'phone': '', 'location': ''},
        }),
      },
      {
        'id': Uuid().v4(),
        'name': 'Design Studio',
        'description': 'Sophisticated template for design agencies and creative studios.',
        'category': 'Creative',
        'is_featured': false,
        'downloads': 890,
        'content': json.encode({
          'sections': ['about', 'services', 'portfolio', 'team', 'contact'],
          'about': {'title': 'About Us', 'text': 'A creative studio specializing in...'},
          'services': {'title': 'Our Services', 'items': []},
          'portfolio': {'title': 'Our Work', 'items': []},
          'team': {'title': 'The Team', 'text': 'Meet our talented team...'},
          'contact': {'title': 'Work With Us', 'email': '', 'phone': '', 'location': ''},
        }),
      },
      {
        'id': Uuid().v4(),
        'name': 'Ultra Minimal',
        'description': 'Extremely clean and minimal design. Less is more with this elegant template.',
        'category': 'Minimal',
        'is_featured': false,
        'downloads': 720,
        'content': json.encode({
          'sections': ['about', 'work', 'contact'],
          'about': {'title': 'About', 'text': 'Simple. Elegant. Effective.'},
          'work': {'title': 'Work', 'items': []},
          'contact': {'title': 'Contact', 'email': '', 'phone': '', 'location': ''},
        }),
      },
    ];
    
    for (final template in templates) {
      await _connection!.execute(
        '''INSERT INTO templates (id, name, description, category, content, is_featured, is_approved, downloads)
           VALUES (\$1, \$2, \$3, \$4, \$5, \$6, true, \$7)
           ON CONFLICT (id) DO NOTHING''',
        parameters: [
          template['id'],
          template['name'],
          template['description'],
          template['category'],
          template['content'],
          template['is_featured'],
          template['downloads'],
        ],
      );
    }
  }
}

// JWT Helper
class JwtHelper {
  static String generateToken(String userId) {
    final payload = {
      'userId': userId,
      'exp': DateTime.now().add(Duration(days: 7)).millisecondsSinceEpoch,
    };
    final header = base64Url.encode(utf8.encode(json.encode({'alg': 'HS256', 'typ': 'JWT'})));
    final body = base64Url.encode(utf8.encode(json.encode(payload)));
    final signature = base64Url.encode(
      Hmac(sha256, utf8.encode(Config.jwtSecret)).convert(utf8.encode('$header.$body')).bytes
    );
    return '$header.$body.$signature';
  }
  
  static Map<String, dynamic>? verifyToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final signature = base64Url.encode(
        Hmac(sha256, utf8.encode(Config.jwtSecret))
          .convert(utf8.encode('${parts[0]}.${parts[1]}')).bytes
      );
      
      if (signature != parts[2]) return null;
      
      final payload = json.decode(utf8.decode(base64Url.decode(parts[1]))) as Map<String, dynamic>;
      if (payload['exp'] < DateTime.now().millisecondsSinceEpoch) return null;
      
      return payload;
    } catch (e) {
      return null;
    }
  }
}

// Middleware
Middleware authMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.forbidden(json.encode({'error': 'Unauthorized'}));
      }
      
      final token = authHeader.substring(7);
      final payload = JwtHelper.verifyToken(token);
      
      if (payload == null) {
        return Response.forbidden(json.encode({'error': 'Invalid token'}));
      }
      
      return innerHandler(request.change(context: {'userId': payload['userId']}));
    };
  };
}

// Auth Handler
class AuthHandler {
  static Future<Response> register(Request request) async {
    try {
      final body = json.decode(await request.readAsString()) as Map<String, dynamic>;
      final email = body['email']?.toString().trim();
      final username = body['username']?.toString().trim();
      final password = body['password']?.toString();
      final fullName = body['fullName']?.toString();
      
      if (email == null || username == null || password == null) {
        return Response.badRequest(body: json.encode({'error': 'Missing required fields'}));
      }
      
      if (password.length < 6) {
        return Response.badRequest(body: json.encode({'error': 'Password must be at least 6 characters'}));
      }
      
      final passwordHash = sha256.convert(utf8.encode(password)).toString();
      final userId = Uuid().v4();
      
      final conn = await Database.connection;
      await conn.execute(
        'INSERT INTO users (id, email, username, password_hash, full_name) VALUES (\$1, \$2, \$3, \$4, \$5)',
        parameters: [userId, email, username, passwordHash, fullName],
      );
      
      final token = JwtHelper.generateToken(userId);
      
      return Response.ok(json.encode({
        'token': token,
        'user': {
          'id': userId,
          'email': email,
          'username': username,
          'fullName': fullName,
        }
      }), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: json.encode({'error': 'Registration failed: ${e.toString()}'}));
    }
  }
  
  static Future<Response> login(Request request) async {
    try {
      final body = json.decode(await request.readAsString()) as Map<String, dynamic>;
      final email = body['email']?.toString().trim();
      final password = body['password']?.toString();
      
      if (email == null || password == null) {
        return Response.badRequest(body: json.encode({'error': 'Missing credentials'}));
      }
      
      final passwordHash = sha256.convert(utf8.encode(password)).toString();
      
      final conn = await Database.connection;
      final result = await conn.execute(
        'SELECT id, email, username, full_name, avatar_url, role FROM users WHERE email = \$1 AND password_hash = \$2',
        parameters: [email, passwordHash],
      );
      
      if (result.isEmpty) {
        return Response.forbidden(json.encode({'error': 'Invalid credentials'}));
      }
      
      final user = result.first.toColumnMap();
      final token = JwtHelper.generateToken(user['id'].toString());
      
      return Response.ok(json.encode({
        'token': token,
        'user': {
          'id': user['id'],
          'email': user['email'],
          'username': user['username'],
          'fullName': user['full_name'],
          'avatarUrl': user['avatar_url'],
          'role': user['role'],
        }
      }), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: json.encode({'error': 'Login failed'}));
    }
  }
  
  static Future<Response> getProfile(Request request) async {
    try {
      final userId = request.context['userId'] as String;
      
      final conn = await Database.connection;
      final result = await conn.execute(
        'SELECT id, email, username, full_name, avatar_url, role, created_at FROM users WHERE id = \$1',
        parameters: [userId],
      );
      
      if (result.isEmpty) {
        return Response.notFound(json.encode({'error': 'User not found'}));
      }
      
      final user = result.first.toColumnMap();
      return Response.ok(json.encode({
        'id': user['id'],
        'email': user['email'],
        'username': user['username'],
        'fullName': user['full_name'],
        'avatarUrl': user['avatar_url'],
        'role': user['role'],
        'createdAt': user['created_at'].toString(),
      }), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: json.encode({'error': 'Failed to fetch profile'}));
    }
  }
}

// Portfolio Handler
class PortfolioHandler {
  static Future<Response> create(Request request) async {
    try {
      final userId = request.context['userId'] as String;
      final body = json.decode(await request.readAsString()) as Map<String, dynamic>;
      
      final title = body['title']?.toString();
      final slug = body['slug']?.toString().trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9-]'), '-');
      final content = body['content'] ?? {};
      final templateId = body['templateId'];
      
      if (title == null || title.isEmpty) {
        return Response.badRequest(body: json.encode({'error': 'Title is required'}));
      }
      
      if (slug == null || slug.isEmpty) {
        return Response.badRequest(body: json.encode({'error': 'Slug is required'}));
      }
      
      final conn = await Database.connection;
      
      // Check if slug already exists for this user
      final existing = await conn.execute(
        'SELECT id FROM portfolios WHERE slug = \$1 AND user_id = \$2',
        parameters: [slug, userId],
      );
      
      if (existing.isNotEmpty) {
        return Response.badRequest(body: json.encode({'error': 'A portfolio with this slug already exists'}));
      }
      
      final portfolioId = Uuid().v4();
      
      await conn.execute(
        'INSERT INTO portfolios (id, user_id, title, slug, template_id, content) VALUES (\$1, \$2, \$3, \$4, \$5, \$6)',
        parameters: [portfolioId, userId, title, slug, templateId, json.encode(content)],
      );
      
      return Response.ok(json.encode({
        'id': portfolioId,
        'title': title,
        'slug': slug,
        'content': content,
      }), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      print('Create portfolio error: $e');
      return Response.internalServerError(body: json.encode({'error': 'Failed to create portfolio: ${e.toString()}'}));
    }
  }
  
  static Future<Response> list(Request request) async {
    try {
      final userId = request.context['userId'] as String;
      final conn = await Database.connection;
      
      final result = await conn.execute(
        'SELECT id, title, slug, is_published, created_at, updated_at FROM portfolios WHERE user_id = \$1 ORDER BY updated_at DESC',
        parameters: [userId],
      );
      
      final portfolios = result.map((row) {
        final data = row.toColumnMap();
        return {
          'id': data['id'],
          'title': data['title'],
          'slug': data['slug'],
          'isPublished': data['is_published'],
          'createdAt': data['created_at'].toString(),
          'updatedAt': data['updated_at'].toString(),
        };
      }).toList();
      
      return Response.ok(json.encode(portfolios), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: json.encode({'error': 'Failed to fetch portfolios'}));
    }
  }
  
  static Future<Response> getById(Request request, String id) async {
    try {
      final userId = request.context['userId'] as String;
      final conn = await Database.connection;
      
      final result = await conn.execute(
        'SELECT * FROM portfolios WHERE id = \$1 AND user_id = \$2',
        parameters: [id, userId],
      );
      
      if (result.isEmpty) {
        return Response.notFound(json.encode({'error': 'Portfolio not found or access denied'}));
      }
      
      final data = result.first.toColumnMap();
      
      // Handle content - it might be a String (JSON) or already decoded Map
      dynamic content;
      if (data['content'] is String) {
        content = json.decode(data['content'] as String);
      } else {
        content = data['content']; // Already decoded
      }
      
      return Response.ok(json.encode({
        'id': data['id'],
        'title': data['title'],
        'slug': data['slug'],
        'content': content,
        'isPublished': data['is_published'],
        'theme': data['theme'],
        'createdAt': data['created_at'].toString(),
        'updatedAt': data['updated_at'].toString(),
      }), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: json.encode({'error': 'Failed to fetch portfolio: ${e.toString()}'}));
    }
  }
  
  static Future<Response> update(Request request, String id) async {
    try {
      final userId = request.context['userId'] as String;
      final body = json.decode(await request.readAsString()) as Map<String, dynamic>;
      
      final title = body['title']?.toString();
      final slug = body['slug']?.toString().trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9-]'), '-');
      final content = body['content'] ?? {};
      
      if (title == null || title.isEmpty) {
        return Response.badRequest(body: json.encode({'error': 'Title is required'}));
      }
      
      if (slug == null || slug.isEmpty) {
        return Response.badRequest(body: json.encode({'error': 'Slug is required'}));
      }
      
      final conn = await Database.connection;
      
      // Check ownership
      final ownership = await conn.execute(
        'SELECT id FROM portfolios WHERE id = \$1 AND user_id = \$2',
        parameters: [id, userId],
      );
      
      if (ownership.isEmpty) {
        return Response.forbidden(json.encode({'error': 'Portfolio not found or access denied'}));
      }
      
      // Check if slug already exists for another portfolio by this user
      final existing = await conn.execute(
        'SELECT id FROM portfolios WHERE slug = \$1 AND user_id = \$2 AND id != \$3',
        parameters: [slug, userId, id],
      );
      
      if (existing.isNotEmpty) {
        return Response.badRequest(body: json.encode({'error': 'A portfolio with this slug already exists'}));
      }
      
      final result = await conn.execute(
        'UPDATE portfolios SET title = \$1, slug = \$2, content = \$3, updated_at = CURRENT_TIMESTAMP WHERE id = \$4 AND user_id = \$5',
        parameters: [title, slug, json.encode(content), id, userId],
      );
      
      if (result.affectedRows == 0) {
        return Response.notFound(json.encode({'error': 'Portfolio not found'}));
      }
      
      return Response.ok(json.encode({
        'id': id,
        'title': title,
        'slug': slug,
        'content': content,
      }), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      print('Update portfolio error: $e');
      return Response.internalServerError(body: json.encode({'error': 'Failed to update portfolio: ${e.toString()}'}));
    }
  }
  
  static Future<Response> getBySlug(Request request, String slug) async {
    try {
      final conn = await Database.connection;
      final result = await conn.execute(
        '''SELECT p.*, u.username, u.full_name FROM portfolios p 
           JOIN users u ON p.user_id = u.id 
           WHERE p.slug = \$1 AND p.is_published = true''',
        parameters: [slug],
      );
      
      if (result.isEmpty) {
        return Response.notFound(json.encode({'error': 'Portfolio not found'}));
      }
      
      final data = result.first.toColumnMap();
      
      // Handle content - it might be a String (JSON) or already decoded Map
      dynamic content;
      if (data['content'] is String) {
        content = json.decode(data['content'] as String);
      } else {
        content = data['content']; // Already decoded
      }
      
      // Track view
      final analyticsId = Uuid().v4();
      String ipAddress = 'unknown';
      try {
        final connectionInfo = request.context['shelf.io.connection_info'];
        if (connectionInfo != null) {
          ipAddress = connectionInfo.toString();
        }
      } catch (e) {
        // Ignore errors getting IP
      }
      
      await conn.execute(
        'INSERT INTO analytics (id, portfolio_id, event_type, ip_address) VALUES (\$1, \$2, \$3, \$4)',
        parameters: [analyticsId, data['id'], 'view', ipAddress],
      );
      
      return Response.ok(json.encode({
        'id': data['id'],
        'title': data['title'],
        'slug': data['slug'],
        'content': content,
        'theme': data['theme'],
        'author': {
          'username': data['username'],
          'fullName': data['full_name'],
        }
      }), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: json.encode({'error': 'Failed to fetch portfolio'}));
    }
  }
  
  static Future<Response> publish(Request request, String id) async {
    try {
      final userId = request.context['userId'] as String;
      final conn = await Database.connection;
      
      // Check ownership first
      final ownership = await conn.execute(
        'SELECT id FROM portfolios WHERE id = \$1 AND user_id = \$2',
        parameters: [id, userId],
      );
      
      if (ownership.isEmpty) {
        return Response.forbidden(json.encode({'error': 'Portfolio not found or access denied'}));
      }
      
      final result = await conn.execute(
        'UPDATE portfolios SET is_published = true, updated_at = CURRENT_TIMESTAMP WHERE id = \$1 AND user_id = \$2',
        parameters: [id, userId],
      );
      
      if (result.affectedRows == 0) {
        return Response.notFound(json.encode({'error': 'Portfolio not found'}));
      }
      
      return Response.ok(json.encode({'message': 'Portfolio published'}), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      print('Publish error: $e');
      return Response.internalServerError(body: json.encode({'error': 'Failed to publish portfolio: ${e.toString()}'}));
    }
  }
  
  static Future<Response> delete(Request request, String id) async {
    try {
      final userId = request.context['userId'] as String;
      final conn = await Database.connection;
      
      // Check ownership
      final ownership = await conn.execute(
        'SELECT id FROM portfolios WHERE id = \$1 AND user_id = \$2',
        parameters: [id, userId],
      );
      
      if (ownership.isEmpty) {
        return Response.forbidden(json.encode({'error': 'Access denied'}));
      }
      
      // Delete the portfolio (CASCADE will handle related analytics)
      await conn.execute(
        'DELETE FROM portfolios WHERE id = \$1 AND user_id = \$2',
        parameters: [id, userId],
      );
      
      return Response.ok(json.encode({'message': 'Portfolio deleted successfully'}), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: json.encode({'error': 'Failed to delete portfolio: ${e.toString()}'}));
    }
  }
}

// Template Handler
class TemplateHandler {
  static Future<Response> list(Request request) async {
    try {
      final conn = await Database.connection;
      final result = await conn.execute(
        'SELECT id, name, description, thumbnail_url, category, is_featured, downloads FROM templates WHERE is_approved = true ORDER BY is_featured DESC, downloads DESC',
      );
      
      final templates = result.map((row) {
        final data = row.toColumnMap();
        return {
          'id': data['id'],
          'name': data['name'],
          'description': data['description'],
          'thumbnailUrl': data['thumbnail_url'],
          'category': data['category'],
          'isFeatured': data['is_featured'],
          'downloads': data['downloads'],
        };
      }).toList();
      
      return Response.ok(json.encode(templates), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: json.encode({'error': 'Failed to fetch templates'}));
    }
  }
}

// Analytics Handler
class AnalyticsHandler {
  static Future<Response> getPortfolioAnalytics(Request request, String portfolioId) async {
    try {
      final userId = request.context['userId'] as String;
      final conn = await Database.connection;
      
      // Verify ownership
      final ownership = await conn.execute(
        'SELECT id FROM portfolios WHERE id = \$1 AND user_id = \$2',
        parameters: [portfolioId, userId],
      );
      
      if (ownership.isEmpty) {
        return Response.forbidden(json.encode({'error': 'Access denied'}));
      }
      
      final views = await conn.execute(
        'SELECT COUNT(*) as count FROM analytics WHERE portfolio_id = \$1 AND event_type = \$2',
        parameters: [portfolioId, 'view'],
      );
      
      final clicks = await conn.execute(
        'SELECT COUNT(*) as count FROM analytics WHERE portfolio_id = \$1 AND event_type = \$2',
        parameters: [portfolioId, 'click'],
      );
      
      return Response.ok(json.encode({
        'views': views.first.toColumnMap()['count'],
        'clicks': clicks.first.toColumnMap()['count'],
      }), headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: json.encode({'error': 'Failed to fetch analytics'}));
    }
  }
}

void main() async {
  final router = Router();
  
  // Auth routes
  router.post('/api/auth/register', AuthHandler.register);
  router.post('/api/auth/login', AuthHandler.login);
  router.get('/api/auth/profile', Pipeline().addMiddleware(authMiddleware()).addHandler(AuthHandler.getProfile));
  
  // Portfolio routes
  router.post('/api/portfolios', Pipeline().addMiddleware(authMiddleware()).addHandler(PortfolioHandler.create));
  router.get('/api/portfolios', Pipeline().addMiddleware(authMiddleware()).addHandler(PortfolioHandler.list));
  router.get('/api/portfolios/id/<id>', Pipeline().addMiddleware(authMiddleware()).addHandler((Request request) {
    // Path will be: /api/portfolios/id/{uuid}
    // Extract ID from the last path segment
    final pathSegments = request.url.pathSegments;
    final id = pathSegments.isNotEmpty ? pathSegments.last : '';
    if (id.isEmpty) {
      return Response.badRequest(body: json.encode({'error': 'Portfolio ID is required'}));
    }
    return PortfolioHandler.getById(request, id);
  }));
  router.put('/api/portfolios/<id>', Pipeline().addMiddleware(authMiddleware()).addHandler((Request request) {
    final id = request.url.pathSegments.last;
    return PortfolioHandler.update(request, id);
  }));
  router.get('/api/portfolios/<slug>', (Request request, String slug) => PortfolioHandler.getBySlug(request, slug));
  router.post('/api/portfolios/<id>/publish', Pipeline().addMiddleware(authMiddleware()).addHandler((Request request) {
    final pathSegments = request.url.pathSegments;
    // Path: /api/portfolios/{id}/publish
    // Segments: ['api', 'portfolios', '{id}', 'publish']
    // So ID is at index 2 (before 'publish' which is at index 3)
    final idIndex = pathSegments.length - 2;
    if (idIndex < 0 || idIndex >= pathSegments.length) {
      return Response.badRequest(body: json.encode({'error': 'Invalid portfolio ID'}));
    }
    final id = pathSegments[idIndex];
    return PortfolioHandler.publish(request, id);
  }));
  router.delete('/api/portfolios/<id>', Pipeline().addMiddleware(authMiddleware()).addHandler((Request request) {
    final id = request.url.pathSegments.last;
    return PortfolioHandler.delete(request, id);
  }));
  
  // Template routes
  router.get('/api/templates', TemplateHandler.list);
  
  // Analytics routes
  router.get('/api/analytics/<portfolioId>', Pipeline().addMiddleware(authMiddleware()).addHandler((Request request) {
    final portfolioId = request.url.pathSegments.last;
    return AnalyticsHandler.getPortfolioAnalytics(request, portfolioId);
  }));
  
  final handler = Pipeline()
    .addMiddleware(logRequests())
    .addMiddleware((Handler handler) {
      return (Request request) async {
        // Handle OPTIONS requests for CORS preflight
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
          });
        }
        
        final response = await handler(request);
        return response.change(headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
        });
      };
    })
    .addHandler(router);
  
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, Config.port);
  print('Server running on port ${server.port}');
}