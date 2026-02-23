# ElderCare App - User Context Access Guide

## Overview
This guide explains how to access and use user context information throughout the ElderCare application.

---

## User Context Sources

### 1. **UserProvider** (Recommended)
The primary way to access user information in the app.

```dart
import 'package:provider/provider.dart';
import 'user_provider.dart';

// In a widget
final userProvider = Provider.of<UserProvider>(context);

// Access user information
String? userId = userProvider.userId;
String? email = userProvider.userEmail;
String? name = userProvider.userName;
bool isLoggedIn = userProvider.isLoggedIn;
```

**Available Properties:**
- `userId` - Unique user identifier (UUID)
- `userEmail` - User's email address
- `userName` - User's display name
- `isLoggedIn` - Boolean indicating login status

**Example Usage:**
```dart
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${userProvider.userName}'),
      ),
      body: Center(
        child: Text('Email: ${userProvider.userEmail}'),
      ),
    );
  }
}
```

---

### 2. **Supabase Auth** (Direct Access)
Access the currently authenticated user directly from Supabase.

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

// Get current user
final user = Supabase.instance.client.auth.currentUser;

// Access user information
String? userId = user?.id;
String? email = user?.email;
DateTime? createdAt = user?.createdAt;
```

**Available Properties:**
- `id` - User ID (UUID)
- `email` - User's email
- `phone` - User's phone number
- `createdAt` - Account creation timestamp
- `lastSignInAt` - Last login timestamp
- `userMetadata` - Custom metadata

**Example Usage:**
```dart
void _loadUserData() {
  final user = Supabase.instance.client.auth.currentUser;
  
  if (user != null) {
    print('User ID: ${user.id}');
    print('Email: ${user.email}');
    print('Created: ${user.createdAt}');
  }
}
```

---

### 3. **Auth State Stream** (Real-time Updates)
Listen to authentication state changes.

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

// Listen to auth state changes
Supabase.instance.client.auth.onAuthStateChange.listen((data) {
  final AuthChangeEvent event = data.event;
  final Session? session = data.session;
  
  if (event == AuthChangeEvent.signedIn) {
    print('User signed in');
    print('User ID: ${session?.user.id}');
  } else if (event == AuthChangeEvent.signedOut) {
    print('User signed out');
  }
});
```

---

## Accessing User Data in Different Contexts

### In StatefulWidget
```dart
class MedicationsPage extends StatefulWidget {
  @override
  State<MedicationsPage> createState() => _MedicationsPageState();
}

class _MedicationsPageState extends State<MedicationsPage> {
  @override
  void initState() {
    super.initState();
    _loadUserMedications();
  }

  Future<void> _loadUserMedications() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;
    
    if (userId == null) return;
    
    // Query user's medications
    final response = await Supabase.instance.client
      .from('medications')
      .select()
      .eq('user_id', userId);
    
    // Process response
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // UI code
    );
  }
}
```

### In StatelessWidget
```dart
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(userProvider.userName ?? 'Profile'),
      ),
      body: Center(
        child: Text(userProvider.userEmail ?? 'No email'),
      ),
    );
  }
}
```

### In Dialog
```dart
void _showUserDialog(BuildContext context) {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('User Info'),
      content: Text('User: ${userProvider.userName}'),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
```

---

## Common Use Cases

### 1. **Load User-Specific Data**
```dart
Future<void> _loadUserData() async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final userId = userProvider.userId;
  
  if (userId == null) {
    print('User not authenticated');
    return;
  }
  
  try {
    final response = await Supabase.instance.client
      .from('medications')
      .select()
      .eq('user_id', userId);
    
    setState(() {
      _medications = List<Map<String, dynamic>>.from(response);
    });
  } catch (e) {
    print('Error loading data: $e');
  }
}
```

### 2. **Insert User-Specific Data**
```dart
Future<void> _addMedication(String name, String dosage) async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final userId = userProvider.userId;
  
  if (userId == null) return;
  
  try {
    await Supabase.instance.client.from('medications').insert({
      'user_id': userId,
      'name': name,
      'dosage': dosage,
      'frequency': 'Once daily',
    });
    
    _loadUserData(); // Refresh data
  } catch (e) {
    print('Error adding medication: $e');
  }
}
```

### 3. **Update User Settings**
```dart
Future<void> _updateNotificationSettings(bool emailNotifications) async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final userId = userProvider.userId;
  
  if (userId == null) return;
  
  try {
    await Supabase.instance.client
      .from('notification_settings')
      .upsert({
        'user_id': userId,
        'email_notifications': emailNotifications,
        'updated_at': DateTime.now().toIso8601String(),
      });
  } catch (e) {
    print('Error updating settings: $e');
  }
}
```

### 4. **Delete User Data**
```dart
Future<void> _deleteMedication(int medicationId) async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final userId = userProvider.userId;
  
  if (userId == null) return;
  
  try {
    await Supabase.instance.client
      .from('medications')
      .delete()
      .eq('id', medicationId)
      .eq('user_id', userId); // Ensure user owns the record
    
    _loadUserData(); // Refresh data
  } catch (e) {
    print('Error deleting medication: $e');
  }
}
```

### 5. **Display User Information**
```dart
Widget _buildUserProfile() {
  final userProvider = Provider.of<UserProvider>(context);
  
  return Column(
    children: [
      Text(
        'Name: ${userProvider.userName ?? 'Unknown'}',
        style: const TextStyle(fontSize: 16),
      ),
      Text(
        'Email: ${userProvider.userEmail ?? 'Unknown'}',
        style: const TextStyle(fontSize: 14),
      ),
      Text(
        'ID: ${userProvider.userId ?? 'Unknown'}',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    ],
  );
}
```

---

## User Context in Different Pages

### MedicationsPage
```dart
// Load medications for current user
final userProvider = Provider.of<UserProvider>(context, listen: false);
final userId = userProvider.userId ?? Supabase.instance.client.auth.currentUser?.id;

final response = await Supabase.instance.client
  .from('medications')
  .select()
  .eq('user_id', userId);
```

### NotificationsPage
```dart
// Load notification settings for current user
final userProvider = Provider.of<UserProvider>(context, listen: false);
final userId = userProvider.userId ?? Supabase.instance.client.auth.currentUser?.id;

final response = await Supabase.instance.client
  .from('notification_settings')
  .select()
  .eq('user_id', userId)
  .maybeSingle();
```

### HelpSupportPage
```dart
// Submit support request with user info
final userProvider = Provider.of<UserProvider>(context, listen: false);
final userId = userProvider.userId ?? Supabase.instance.client.auth.currentUser?.id;

await Supabase.instance.client.from('support_requests').insert({
  'user_id': userId,
  'subject': subject,
  'message': message,
  'category': category,
});
```

### AccountPage
```dart
// Display user profile information
final userProvider = Provider.of<UserProvider>(context);

Text(userProvider.userName ?? 'User')
Text(userProvider.userEmail ?? '')
```

---

## Error Handling with User Context

### Check User Authentication
```dart
Future<void> _checkUserAuthentication() async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  
  if (userProvider.userId == null) {
    // User not authenticated
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please log in first')),
    );
    return;
  }
  
  // Proceed with user-specific operations
}
```

### Handle Missing User Data
```dart
Future<void> _loadData() async {
  try {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId;
    
    if (userId == null) {
      throw Exception('User ID not available');
    }
    
    // Load data
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
```

---

## Best Practices

### 1. **Always Check for Null**
```dart
// ✅ Good
final userId = userProvider.userId;
if (userId == null) return;

// ❌ Bad
final userId = userProvider.userId!; // Can crash if null
```

### 2. **Use listen: false in initState**
```dart
// ✅ Good
@override
void initState() {
  super.initState();
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  _loadData(userProvider.userId);
}

// ❌ Bad
@override
void initState() {
  super.initState();
  final userProvider = Provider.of<UserProvider>(context); // Can cause issues
}
```

### 3. **Filter by User ID in Queries**
```dart
// ✅ Good - Only get user's data
final response = await Supabase.instance.client
  .from('medications')
  .select()
  .eq('user_id', userId);

// ❌ Bad - Gets all data
final response = await Supabase.instance.client
  .from('medications')
  .select();
```

### 4. **Use RLS Policies**
```sql
-- ✅ Good - RLS policy ensures user can only access their data
CREATE POLICY "Users can view their own medications"
  ON medications FOR SELECT
  USING (auth.uid() = user_id);

-- ❌ Bad - No RLS, anyone can access any data
```

### 5. **Handle Async Operations Properly**
```dart
// ✅ Good
Future<void> _loadData() async {
  setState(() => _isLoading = true);
  try {
    // Load data
  } catch (e) {
    // Handle error
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

// ❌ Bad - No loading state or error handling
void _loadData() {
  // Load data without feedback
}
```

---

## Debugging User Context

### Print User Information
```dart
void _debugUserContext() {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final supabaseUser = Supabase.instance.client.auth.currentUser;
  
  print('=== User Context Debug ===');
  print('UserProvider ID: ${userProvider.userId}');
  print('UserProvider Email: ${userProvider.userEmail}');
  print('UserProvider Name: ${userProvider.userName}');
  print('Supabase ID: ${supabaseUser?.id}');
  print('Supabase Email: ${supabaseUser?.email}');
  print('========================');
}
```

### Check Authentication State
```dart
void _checkAuthState() {
  final session = Supabase.instance.client.auth.currentSession;
  
  if (session != null) {
    print('User is authenticated');
    print('Session expires at: ${session.expiresAt}');
  } else {
    print('User is not authenticated');
  }
}
```

---

## Summary

| Source | Use Case | Example |
|--------|----------|---------|
| UserProvider | Display user info in UI | `userProvider.userName` |
| Supabase Auth | Get current user directly | `Supabase.instance.client.auth.currentUser` |
| Auth Stream | Listen to auth changes | `onAuthStateChange.listen()` |
| Database Query | Load user-specific data | `.eq('user_id', userId)` |

---

## Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Provider Package](https://pub.dev/packages/provider)
- [Supabase Flutter SDK](https://pub.dev/packages/supabase_flutter)
- [SUPABASE_SETUP.md](./SUPABASE_SETUP.md)
- [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md)

---

## Questions?

For more information about user context or implementation details, refer to the documentation files or contact support.
