# Frontend README

## HRMS Flutter Frontend

A cross-platform Flutter application for the HRMS (Human Resource Management System).

## Features

- ✅ Authentication (Login/Register)
- ✅ Dashboard with organization stats
- ✅ Dynamic navigation from backend menus
- ✅ Role-based permissions
- ✅ Secure token storage
- ✅ API integration with interceptors
- ✅ Material 3 design

## Setup

### Prerequisites

- Flutter SDK 3.9 or higher
- Dart 3.9 or higher

### Installation

```bash
flutter pub get
```

### Running the App

**Web:**
```bash
flutter run -d chrome
```

**iOS:**
```bash
flutter run -d ios
```

**Android:**
```bash
flutter run -d android
```

## Configuration

### Backend URL

Update the API base URL in `lib/core/config/app_config.dart`:
```dart
static const String apiBaseUrl = 'http://localhost:8000';
```

## Project Structure

```
lib/
├── core/                 
│   ├── config/          # App configuration
│   ├── theme/           # App theming
│   ├── constants/       
│   └── utils/           
├── data/                
│   ├── models/          # Data models
│   ├── services/        # API services
│   └── repositories/    
├── presentation/        
│   ├── screens/         # UI screens
│   │   ├── auth/        # Login, Register
│   │   ├── dashboard/   # Dashboard
│   │   └── ...
│   ├── widgets/         # Reusable widgets
│   └── navigation/      
└── state/               
    └── providers/       # State management
```

## Dependencies

### Core
- `dio` - HTTP client
- `provider` - State management
- `go_router` - Routing

### Storage
- `flutter_secure_storage` - Secure token storage
- `shared_preferences` - Local preferences

### UI
- `flutter_svg` - SVG support
- `cached_network_image` - Image caching
- `flutter_spinkit` - Loading indicators
- `fl_chart` - Charts and graphs

### Media
- `video_player` - Video playback
- `chewie` - Video player UI
- `image_picker` - Image selection
- `file_picker` - File selection

## Code Quality

Run analyzer:
```bash
flutter analyze
```

Run tests:
```bash
flutter test
```

## Screens

### Authentication
- **Login Screen** - Email/password authentication
- **Register Screen** - User and organization registration

### Dashboard
- **Dashboard Screen** - Overview with stats, menus, quick actions

### Coming Soon
- Users Management
- Organization Management
- Learning Management
- Recruitment
- Attendance & Leave
- Shift Management
- Payroll

## State Management

Using **Provider** pattern:

```dart
// Access auth state
final authProvider = Provider.of<AuthProvider>(context);

// Or with Consumer
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    return Text(authProvider.user?.fullName ?? '');
  },
)
```

## API Integration

All API calls go through `ApiService`:

```dart
final apiService = ApiService();
final response = await apiService.get('/users/');
```

Tokens are automatically injected via interceptors.

## License

MIT
