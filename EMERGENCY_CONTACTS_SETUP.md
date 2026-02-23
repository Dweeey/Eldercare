# Emergency Contacts - Supabase Setup Guide

## Overview
The Emergency Contacts page has been updated to use Supabase database instead of local database helper. This guide explains how to set up the required table.

---

## Database Table Schema

### emergency_contacts Table

```sql
CREATE TABLE emergency_contacts (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  relationship VARCHAR(100),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX idx_emergency_contacts_user_id ON emergency_contacts(user_id);
```

---

## Setup Instructions

### Step 1: Create the Table in Supabase

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Click **New Query**
4. Copy and paste the SQL above
5. Click **Run**

### Step 2: Enable Row Level Security (RLS)

```sql
-- Enable RLS on emergency_contacts table
ALTER TABLE emergency_contacts ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own emergency contacts
CREATE POLICY "Users can view their own emergency contacts"
  ON emergency_contacts FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own emergency contacts
CREATE POLICY "Users can insert their own emergency contacts"
  ON emergency_contacts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own emergency contacts
CREATE POLICY "Users can update their own emergency contacts"
  ON emergency_contacts FOR UPDATE
  USING (auth.uid() = user_id);

-- Policy: Users can delete their own emergency contacts
CREATE POLICY "Users can delete their own emergency contacts"
  ON emergency_contacts FOR DELETE
  USING (auth.uid() = user_id);
```

---

## Code Changes

### Updated Imports
```dart
import 'package:supabase_flutter/supabase_flutter.dart';
// Removed: import 'database_helper.dart';
```

### Key Methods Updated

#### 1. _loadContacts()
Now queries Supabase instead of local database:
```dart
Future<void> _loadContacts() async {
  try {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userId ?? _supabase.auth.currentUser?.id;

    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final response = await _supabase
        .from('emergency_contacts')
        .select()
        .eq('user_id', userId);

    setState(() {
      _contacts = List<Map<String, dynamic>>.from(response);
      _isLoading = false;
    });
  } catch (e) {
    // Error handling
  }
}
```

#### 2. _addContact()
Inserts contact into Supabase:
```dart
Future<void> _addContact() async {
  // ... dialog code ...
  
  await _supabase.from('emergency_contacts').insert({
    'user_id': userId,
    'name': result['name']!,
    'phone': result['phone']!,
    'relationship': result['relationship']!,
  });
  
  _loadContacts(); // Refresh list
}
```

#### 3. _deleteContact()
Deletes contact from Supabase:
```dart
Future<void> _deleteContact(int contactId, String name) async {
  // ... confirmation dialog ...
  
  await _supabase
      .from('emergency_contacts')
      .delete()
      .eq('id', contactId);
  
  _loadContacts(); // Refresh list
}
```

---

## Features

### ✅ Add Emergency Contact
- User fills in name, phone, and relationship
- Data is saved to Supabase
- List refreshes automatically
- Success message displayed

### ✅ View Emergency Contacts
- All contacts for current user are displayed
- Shows name, phone, and relationship
- Beautiful card-based UI
- Empty state when no contacts

### ✅ Delete Emergency Contact
- Confirmation dialog before deletion
- Contact removed from Supabase
- List refreshes automatically
- Success message displayed

### ✅ Call Contact
- Green phone icon to initiate call
- Shows "Calling..." message
- Ready for integration with phone_caller package

---

## Data Structure

Each emergency contact record contains:

| Field | Type | Description |
|-------|------|-------------|
| id | BIGINT | Unique identifier |
| user_id | UUID | Reference to authenticated user |
| name | VARCHAR(255) | Contact's name |
| phone | VARCHAR(20) | Contact's phone number |
| relationship | VARCHAR(100) | Relationship to user (Family, Friend, Doctor, etc.) |
| created_at | TIMESTAMP | When record was created |
| updated_at | TIMESTAMP | When record was last updated |

---

## User Context Access

The page accesses user information in two ways:

### 1. From UserProvider
```dart
final userProvider = Provider.of<UserProvider>(context, listen: false);
final userId = userProvider.userId;
```

### 2. From Supabase Auth (Fallback)
```dart
final userId = _supabase.auth.currentUser?.id;
```

This ensures the page works even if UserProvider is not fully initialized.

---

## Error Handling

All database operations include try-catch blocks:

```dart
try {
  // Database operation
} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

Errors are displayed to users via SnackBar notifications.

---

## Testing Checklist

- [ ] Table created in Supabase
- [ ] RLS policies enabled
- [ ] Can add a contact
- [ ] Contact appears in list
- [ ] Can delete a contact
- [ ] Contact removed from list
- [ ] Error messages display correctly
- [ ] Loading indicator shows
- [ ] Empty state displays when no contacts
- [ ] User can only see their own contacts

---

## Troubleshooting

### Issue: "Error loading contacts"
**Solution**: 
- Verify user is authenticated
- Check that `emergency_contacts` table exists
- Ensure RLS policies are correct

### Issue: "Error adding contact"
**Solution**:
- Verify all fields are filled in
- Check that user_id is not null
- Ensure RLS insert policy is enabled

### Issue: "Error deleting contact"
**Solution**:
- Verify contact ID is correct
- Check that RLS delete policy is enabled
- Ensure user owns the contact

### Issue: Contacts not loading
**Solution**:
- Check network connection
- Verify Supabase URL and key are correct
- Check that user is authenticated
- Verify RLS select policy is enabled

---

## Security

### Row Level Security (RLS)
- Users can only view their own contacts
- Users can only insert contacts for themselves
- Users can only update their own contacts
- Users can only delete their own contacts

### Data Validation
- Name is required
- Phone number is required
- Relationship is selected from predefined list

### Authentication
- All operations require authenticated user
- User ID is automatically set from auth context

---

## Future Enhancements

- [ ] Edit existing contacts
- [ ] Call integration (using phone_caller package)
- [ ] SMS integration
- [ ] Contact photo/avatar
- [ ] Emergency alert notifications
- [ ] Contact priority levels
- [ ] Bulk contact import/export

---

## Related Files

- `emergency_contacts_page.dart` - Main page implementation
- `SUPABASE_SETUP.md` - General Supabase setup guide
- `USER_CONTEXT_GUIDE.md` - How to access user information

---

## Support

For issues or questions about the emergency contacts feature, refer to the documentation or contact support.
