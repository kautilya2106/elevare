# Elevare - File Structure & Responsibilities

## Project Overview
Elevare is a multi-user portfolio platform with Flutter frontend and Dart backend.

---

## Frontend Files (`frontend/lib/`)

### **Main Application**
- **`main.dart`**
  - Application entry point
  - Sets up Provider for state management (AuthService, ThemeService, ApiService)
  - Configures MaterialApp with light/dark themes
  - Defines all routes: `/`, `/auth`, `/dashboard`, `/builder`, `/templates`, `/settings`
  - Handles dynamic routes for public portfolios (`/p/{slug}`)

### **Screens** (`screens/`)

#### **`landing_page.dart`**
- **Purpose**: Public-facing landing page with marketing content
- **Features**:
  - 3D animated hero section with floating geometric shapes
  - Animation controllers for smooth transitions
  - Sections: Header, Hero, How It Works, Template Preview, Testimonials, About Us, Contact, FAQ, Footer
  - Navigation to auth and templates pages
  - Responsive design with dark mode support

#### **`auth_page.dart`**
- **Purpose**: User authentication (login/register)
- **Features**:
  - Login form with email and password
  - Registration form with email, username, password, full name
  - Integration with AuthService
  - Navigation to dashboard on success
  - Error handling and validation

#### **`dashboard_page.dart`**
- **Purpose**: User's main dashboard for managing portfolios
- **Features**:
  - Sidebar navigation with user profile
  - Grid view of all user portfolios
  - Portfolio cards showing title, status (published/draft), last updated
  - Quick actions: Edit, Delete, Copy Link
  - Empty state for new users
  - Floating action button to create new portfolio
  - Theme toggle integration

#### **`portfolio_builder_page.dart`**
- **Purpose**: Main portfolio editing interface
- **Features**:
  - Split-screen layout: Editor panel (left) + Live preview (right)
  - Portfolio settings: Title and URL slug input
  - Section management:
    - Reorderable list of sections
    - Add custom sections
    - Delete sections
    - Edit section content
  - Section types with specialized editors:
    - **About**: Text editor for bio
    - **Experience**: List editor with company, position, dates, location, description
    - **Projects**: List editor with name, description, URL
    - **Skills**: Tag-based editor
    - **Contact**: Email, phone, location fields
    - **Custom**: Generic text editor
  - Real-time preview updates
  - Dark mode toggle for preview
  - Save and Publish buttons
  - Loads existing portfolio if editing

#### **`templates_page.dart`**
- **Purpose**: Browse and select portfolio templates
- **Features**:
  - Grid display of available templates
  - Template categories and descriptions
  - Preview templates
  - Apply template to new portfolio

#### **`public_portfolio_page.dart`**
- **Purpose**: Public view of published portfolios
- **Features**:
  - Displays portfolio by slug from URL
  - Renders all sections with proper formatting
  - Shows author information
  - Analytics tracking on view

#### **`settings_page.dart`**
- **Purpose**: User account settings
- **Features**:
  - Profile editing
  - Theme preferences
  - Account management

### **Services** (`services/`)

#### **`auth_service.dart`**
- **Purpose**: Authentication state management
- **Responsibilities**:
  - User login and registration
  - Token storage and management
  - User data caching
  - Logout functionality
  - Authentication state notifications (ChangeNotifier)

#### **`api_service.dart`**
- **Purpose**: HTTP client for backend communication
- **Responsibilities**:
  - Centralized API base URL configuration
  - HTTP methods: GET, POST, PUT, DELETE
  - Request/response handling
  - JWT token injection in headers
  - Error handling and status code management

#### **`theme_service.dart`**
- **Purpose**: Application theme management
- **Responsibilities**:
  - Light/dark mode switching
  - Theme preference persistence
  - Theme state notifications

### **Widgets** (`widgets/`)

#### **`logo_widget.dart`**
- **Purpose**: Reusable Elevare logo component
- **Features**:
  - Configurable font size
  - Optional tagline display
  - Color customization

#### **`monkey_password_field.dart`**
- **Purpose**: Custom password input field
- **Features**:
  - Password visibility toggle
  - Validation feedback

### **Theme** (`theme/`)

#### **`app_colors.dart`**
- **Purpose**: Centralized color definitions
- **Contains**:
  - Primary, secondary, accent colors
  - Background colors (light/dark)
  - Text colors for different contexts
  - Gradient definitions
  - Status colors (success, error, etc.)

---

## Backend Files (`backend/`)

### **`bin/server.dart`**
- **Purpose**: Main backend server application
- **Structure**:

#### **Configuration (`Config` class)**
- Database connection settings (host, port, name, user, password)
- JWT secret key
- Server port configuration
- Environment variable support

#### **Database (`Database` class)**
- **Purpose**: PostgreSQL connection and schema management
- **Responsibilities**:
  - Connection pooling
  - Table creation:
    - `users` - User accounts
    - `portfolios` - Portfolio data with JSONB content
    - `templates` - Portfolio templates
    - `analytics` - View/click tracking
  - Template seeding (9 pre-built templates)
  - Index creation for performance

#### **JWT Helper (`JwtHelper` class)**
- **Purpose**: JWT token generation and verification
- **Methods**:
  - `generateToken()` - Creates JWT with user ID and expiration
  - `verifyToken()` - Validates token signature and expiration

#### **Middleware (`authMiddleware`)**
- **Purpose**: Authentication verification for protected routes
- **Functionality**:
  - Extracts Bearer token from Authorization header
  - Verifies token validity
  - Injects userId into request context
  - Returns 403 if unauthorized

#### **Auth Handler (`AuthHandler` class)**
- **Endpoints**:
  - `POST /api/auth/register` - User registration
  - `POST /api/auth/login` - User authentication
  - `GET /api/auth/profile` - Get user profile (protected)
- **Features**:
  - Password hashing with SHA-256
  - Email/username uniqueness validation
  - JWT token generation on successful auth

#### **Portfolio Handler (`PortfolioHandler` class)**
- **Endpoints**:
  - `POST /api/portfolios` - Create portfolio (protected)
  - `GET /api/portfolios` - List user's portfolios (protected)
  - `GET /api/portfolios/id/{id}` - Get portfolio by ID (protected)
  - `PUT /api/portfolios/{id}` - Update portfolio (protected)
  - `GET /api/portfolios/{slug}` - Get public portfolio by slug
  - `POST /api/portfolios/{id}/publish` - Publish portfolio (protected)
  - `DELETE /api/portfolios/{id}` - Delete portfolio (protected)
- **Features**:
  - JSONB content storage for flexibility
  - Slug generation and validation
  - Ownership verification
  - Analytics tracking on public views

#### **Template Handler (`TemplateHandler` class)**
- **Endpoints**:
  - `GET /api/templates` - List all approved templates
- **Features**:
  - Returns templates sorted by featured status and downloads
  - Public access (no authentication required)

#### **Analytics Handler (`AnalyticsHandler` class)**
- **Endpoints**:
  - `GET /api/analytics/{portfolioId}` - Get portfolio analytics (protected)
- **Features**:
  - View and click counts
  - Ownership verification

#### **Main Function**
- Sets up Shelf router with all endpoints
- Configures CORS middleware
- Starts HTTP server on configured port
- Request logging middleware

---

## Configuration Files

### **`docker-compose.yml`**
- **Purpose**: Container orchestration
- **Services**:
  - `postgres` - PostgreSQL 15 database container
  - `backend` - Dart backend server container
- **Features**:
  - Environment variable configuration
  - Volume persistence for database
  - Health checks
  - Port mapping

### **`Dockerfile`**
- **Purpose**: Backend container image definition
- **Contains**: Dart SDK setup, dependency installation, server startup

### **`nginx.conf`**
- **Purpose**: Reverse proxy configuration for production
- **Features**: Routing, SSL termination, static file serving

### **`pubspec.yaml`** (Frontend & Backend)
- **Purpose**: Dart/Flutter dependency management
- **Frontend dependencies**: Flutter, Provider, HTTP, SharedPreferences
- **Backend dependencies**: Shelf, Shelf Router, PostgreSQL, Crypto, UUID

---

## Data Flow

### **User Registration/Login Flow**
1. User fills form in `auth_page.dart`
2. `auth_service.dart` calls `api_service.dart`
3. `api_service.dart` sends POST to `/api/auth/register` or `/api/auth/login`
4. `AuthHandler` validates, hashes password, creates user in database
5. JWT token generated and returned
6. `auth_service.dart` stores token and user data
7. Navigation to dashboard

### **Portfolio Creation Flow**
1. User clicks "New Portfolio" in `dashboard_page.dart`
2. Navigates to `portfolio_builder_page.dart`
3. User edits content in editor panel
4. Changes update state, triggering preview refresh
5. User clicks "Save"
6. `api_service.dart` sends POST/PUT to `/api/portfolios`
7. `PortfolioHandler` saves to database with JSONB content
8. Success notification shown

### **Portfolio Publishing Flow**
1. User clicks "Publish" in builder
2. `api_service.dart` sends POST to `/api/portfolios/{id}/publish`
3. `PortfolioHandler` sets `is_published = true`
4. Navigation to `/p/{slug}`
5. `public_portfolio_page.dart` fetches portfolio by slug
6. Analytics event recorded

---

## Key Design Patterns

1. **Provider Pattern** - State management in Flutter
2. **Service Layer** - Separation of business logic
3. **Repository Pattern** - Database abstraction (implicit in handlers)
4. **Middleware Pattern** - Authentication and CORS in backend
5. **RESTful API** - Standard HTTP methods and status codes
6. **JSONB Storage** - Flexible schema for portfolio content

---

## Security Features

- JWT token-based authentication
- Password hashing (SHA-256)
- CORS configuration
- Ownership verification on protected endpoints
- SQL injection prevention (parameterized queries)
- Input validation and sanitization

---

## Performance Optimizations

- Database indexes on frequently queried columns
- Connection pooling
- JSONB for efficient JSON storage and querying
- Flutter's reactive state management for efficient UI updates
- Lazy loading in list views


