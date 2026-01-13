# Task Manager - Flutter Assignment

A complete Flutter mobile application for task management with JSONPlaceholder API integration, offline support, and BLoC state management.

## 📱 Features

### Core Requirements
- ✅ Main screen displaying list of tasks (todos)
- ✅ Floating action button to add new tasks
- ✅ Ability to mark tasks as complete
- ✅ Ability to delete tasks
- ✅ Search functionality to filter todos
- ✅ Pull-to-refresh for todo list
- ✅ Mock login screen with authentication

### Advanced Features
- ✅ BLoC pattern implementation for state management
- ✅ JSONPlaceholder API integration (CRUD operations)
- ✅ Offline support with Hive local storage
- ✅ Optimistic updates for better user experience
- ✅ Connectivity detection (online/offline status)
- ✅ Automatic sync when connection restored
- ✅ Error handling with user feedback

## 🏗️ Architecture

The app follows clean architecture with clear separation of concerns:

```
lib/
├── core/
│   ├── network/     # API client and network utilities
│   ├── storage/     # Hive local storage implementation
│   └── utils/       # App constants and helpers
├── data/
│   ├── models/      # Data models (TaskModel with Hive support)
│   └── repositories/# Repository pattern implementation
├── bloc/            # BLoC pattern (events, states, bloc)
└── presentation/
    ├── screens/     # UI screens (login, task list)
    └── widgets/     # Reusable widgets (task tile)
```

## 🚀 Setup & Installation

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart (3.0 or higher)
- Android Studio / VS Code

### Steps
1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/task-manager.git
   cd task-manager
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter packages pub run build_runner build
   ```
   *If build_runner fails, manually create `task_model.g.dart` with provided code*

4. **Run the application**
   ```bash
   flutter run
   ```

### Login Credentials
- **Email**: `user@example.com`
- **Password**: `password123`

## 🧠 BLoC Pattern Implementation

### Events
```dart
LoadTasks()          // Fetch tasks from API/local
AddTask(title)       // Create new task
UpdateTask(task)     // Update existing task
DeleteTask(id)       // Remove task
ToggleTaskCompletion(task, completed) // Mark complete/incomplete
SearchTasks(query)   // Filter tasks
SyncTasks()          // Sync local changes
```

### States
```dart
TaskState {
  TaskStatus status,          // initial, loading, success, failure, offline
  List<TaskModel> tasks,      // All tasks
  List<TaskModel> filteredTasks, // Filtered tasks for search
  String searchQuery,         // Current search query
  bool isOnline,              // Connectivity status
  bool hasPendingSync,        // Pending sync indicator
  String? errorMessage        // Error messages
}
```

### TaskBloc
Manages all business logic:
- Handles API calls and local storage
- Monitors connectivity changes
- Implements optimistic updates
- Manages search filtering
- Handles error states

## 🔌 API Integration

### Endpoints Used
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/todos` | Retrieve all todos |
| POST | `/todos` | Create new todo |
| PATCH | `/todos/:id` | Update todo (mark as complete) |
| DELETE | `/todos/:id` | Delete todo |

### Error Handling
- Network errors show user-friendly messages
- Offline mode falls back to local storage
- Automatic retry on connectivity restore

## 📶 Offline Support Strategy

### 1. Local Storage with Hive
```dart
// Tasks are stored locally using Hive
await Hive.openBox<TaskModel>('tasks');
await Hive.openBox('app_data');
```

### 2. Optimistic Updates
- UI updates immediately when user performs actions
- Background sync with server when online
- Pending changes queue for offline operations

### 3. Sync Mechanism
```dart
// When connectivity is restored:
1. Check for pending sync tasks
2. Attempt to sync each task with API
3. Update local storage with server responses
4. Clear successfully synced tasks
```

### 4. Connectivity Detection
- Real-time monitoring with `connectivity_plus`
- Visual indicator of online/offline status
- Automatic sync trigger when back online

## 🛠️ Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.3    # State management
  equatable: ^2.0.5       # Value equality
  http: ^1.2.0           # API calls
  hive: ^2.2.3           # Local storage
  hive_flutter: ^1.1.0   # Hive Flutter integration
  connectivity_plus: ^5.0.2 # Network detection
  pull_to_refresh: ^2.0.0 # Pull to refresh
```

## 📁 Code Organization

### Core Layer
- `api_client.dart`: HTTP client for JSONPlaceholder API
- `network_info.dart`: Connectivity detection
- `local_storage.dart`: Hive storage implementation
- `app_constants.dart`: Configuration constants

### Data Layer
- `task_model.dart`: Task data model with Hive support
- `task_repository.dart`: Repository pattern implementation

### BLoC Layer
- `task_event.dart`: All BLoC events
- `task_state.dart`: Application states
- `task_bloc.dart`: Business logic controller

### Presentation Layer
- `login_screen.dart`: Authentication screen
- `task_list_screen.dart`: Main task management screen
- `task_tile.dart`: Reusable task item widget

## 🎯 Design Decisions

### 1. Offline-First Approach
- Local storage as primary data source
- API as synchronization layer
- Better user experience in poor connectivity

### 2. Optimistic UI Updates
- Immediate feedback for user actions
- Background error handling
- Rollback mechanism on failure

### 3. Repository Pattern
- Abstract data source details from business logic
- Easy to switch APIs or storage solutions
- Clean separation of concerns

### 4. BLoC Pattern Choice
- Predictable state management
- Easy testing and debugging
- Scalable for future features

## 🧪 Testing Features

The app includes:
- Form validation on login screen
- Network error simulation (turn off internet)
- Offline mode testing
- Search functionality testing
- Pull-to-refresh testing
- Task CRUD operations testing

## 🚨 Error Scenarios Handled

1. **Network Failure**: Falls back to local storage, shows offline indicator
2. **API Errors**: User-friendly error messages with retry option
3. **Invalid Login**: Form validation with specific error messages
4. **Storage Errors**: Graceful degradation with error notifications
5. **Sync Conflicts**: Last write wins strategy for simplicity

## 📈 Performance Considerations

1. **Efficient Rebuilds**: BLoC minimizes unnecessary UI updates
2. **Lazy Loading**: Tasks loaded only when needed
3. **Local Cache**: Reduces API calls and improves responsiveness
4. **Debounced Search**: Prevents excessive filtering on typing

## 🔮 Future Enhancements

1. **Unit & Integration Tests**: Add comprehensive test suite
2. **Dark Mode**: Theme switching support
3. **Task Categories**: Organize tasks by categories
4. **Due Dates & Reminders**: Time-based task management
5. **Data Export**: Export tasks to CSV/PDF
6. **Biometric Auth**: Fingerprint/Face ID login
7. **Push Notifications**: Task reminders
8. **Multiple Languages**: Internationalization support

## 👨‍💻 Development Challenges & Solutions

### Challenge 1: Offline-Online Data Synchronization
**Solution**: Implemented optimistic updates with pending sync queue. When offline, tasks are saved locally with `isLocal: true` flag. When online, the app checks for pending tasks and syncs them sequentially.

### Challenge 2: Real-time Search with Performance
**Solution**: Used BLoC to manage search state with debouncing. Search updates are batched to prevent excessive filtering and UI rebuilds.

### Challenge 3: Error State Management
**Solution**: Comprehensive error handling in repository layer with clear error states in BLoC. Users get appropriate feedback for different error types.

### Challenge 4: BLoC Complexity Management
**Solution**: Clear event/state separation, private events for internal operations, and proper cleanup of streams and subscriptions.

## 📸 Screenshots

- Login Screen

<img width="372" height="594" alt="Screenshot 2026-01-13 at 1 27 37 PM" src="https://github.com/user-attachments/assets/918359ba-56e6-4bfa-9f1a-355fab55a276" />
<img width="372" height="594" alt="Screenshot 2026-01-13 at 1 27 30 PM" src="https://github.com/user-attachments/assets/4ee89363-ba9e-459f-9be6-c7b5521ed300" />

- Search Functionality

<img width="367" height="594" alt="Screenshot 2026-01-13 at 1 26 04 PM" src="https://github.com/user-attachments/assets/ad213cf8-862e-40f9-8a95-672d22c99556" />
<img width="367" height="594" alt="Screenshot 2026-01-13 at 1 25 53 PM" src="https://github.com/user-attachments/assets/b2bbfe8d-103e-4425-8d84-5e1bc6d41a8f" />

- Add Task Dialog
  
<img width="367" height="594" alt="Screenshot 2026-01-13 at 1 26 08 PM" src="https://github.com/user-attachments/assets/417a1f97-cd2a-4d20-aba3-b886f9cc3cc8" />
<img width="367" height="594" alt="Screenshot 2026-01-13 at 1 26 04 PM" src="https://github.com/user-attachments/assets/71a67315-a7a0-49cb-89ae-122bc95a5af2" />


## 🎥 Video Demonstration

*(Optional: Add link to video demo)*

## 📄 Assignment Requirements Checklist

- [x] Flutter mobile application ✓
- [x] JSONPlaceholder API integration ✓
- [x] BLoC pattern implementation ✓
- [x] Task list display ✓
- [x] Add new tasks ✓
- [x] Mark tasks as complete ✓
- [x] Delete tasks ✓
- [x] Search functionality ✓
- [x] Pull-to-refresh ✓
- [x] Offline support with caching ✓
- [x] Optimistic updates ✓
- [x] Mock authentication ✓
- [x] Error handling ✓
- [x] Clean code organization ✓

## 📝 Submission Details

**Candidate**: Sanket  
**Assignment**: Flutter Task Manager  
**Submission Date**: 13 Jan 2026
**Evaluation Criteria Met**: All requirements fulfilled

## 👤 Author

**Sanket**  
Flutter Developer

## 📄 License

This project is created for assignment purposes.

---

## 🚀 Quick Start Commands

```bash
# Clone and setup
git clone <repository-url>
cd task-manager
flutter pub get
flutter packages pub run build_runner build
flutter run

# Build for production
flutter build apk --release
```

## 🤝 Contributing

This is an assignment project and not open for contributions.

**Submission Ready**: ✅ All requirements implemented and documented  
**Last Updated**: 13 Jan 2026
**Flutter Version**: 3.0+  
**Dart Version**: 3.0+
