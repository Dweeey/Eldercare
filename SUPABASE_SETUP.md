# ElderCare App - Supabase Database Setup Guide

## Overview
This document provides instructions for setting up the Supabase database tables required for the ElderCare application.

---

## Required Tables

### 1. **medications** Table
Stores medication information for users.

```sql
CREATE TABLE medications (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  dosage VARCHAR(100) NOT NULL,
  frequency VARCHAR(100) NOT NULL,
  reason TEXT,
  start_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_medications_user_id ON medications(user_id);
```

---

### 2. **notification_settings** Table
Stores user notification preferences.

```sql
CREATE TABLE notification_settings (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  email_notifications BOOLEAN DEFAULT TRUE,
  push_notifications BOOLEAN DEFAULT TRUE,
  medication_reminders BOOLEAN DEFAULT TRUE,
  appointment_reminders BOOLEAN DEFAULT TRUE,
  emergency_alerts BOOLEAN DEFAULT TRUE,
  health_updates BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_notification_settings_user_id ON notification_settings(user_id);
```

---

### 3. **faqs** Table
Stores frequently asked questions for the Help & Support page.

```sql
CREATE TABLE faqs (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  question VARCHAR(500) NOT NULL,
  answer TEXT NOT NULL,
  category VARCHAR(100),
  "order" INT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_faqs_order ON faqs("order");
```

---

### 4. **emergency_contacts** Table
Stores emergency contact information for users.

```sql
CREATE TABLE emergency_contacts (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  relationship VARCHAR(100) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_emergency_contacts_user_id ON emergency_contacts(user_id);
```

### 5. **support_requests** Table
Stores user support requests.

```sql
CREATE TABLE support_requests (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  subject VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  category VARCHAR(100),
  status VARCHAR(50) DEFAULT 'open',
  response TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_support_requests_user_id ON support_requests(user_id);
CREATE INDEX idx_support_requests_status ON support_requests(status);
```

---

## Setup Instructions

### Step 1: Access Supabase Dashboard
1. Go to [https://supabase.com](https://supabase.com)
2. Sign in to your account
3. Select your ElderCare project

### Step 2: Create Tables
1. Navigate to the **SQL Editor** section
2. Click **New Query**
3. Copy and paste each table creation SQL from above
4. Execute each query one by one

### Step 3: Enable Row Level Security (RLS)
For security, enable RLS on all tables:

```sql
-- Enable RLS on medications
ALTER TABLE medications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own medications"
  ON medications FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own medications"
  ON medications FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own medications"
  ON medications FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own medications"
  ON medications FOR DELETE
  USING (auth.uid() = user_id);

-- Enable RLS on notification_settings
ALTER TABLE notification_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own notification settings"
  ON notification_settings FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notification settings"
  ON notification_settings FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own notification settings"
  ON notification_settings FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Enable RLS on support_requests
ALTER TABLE support_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own support requests"
  ON support_requests FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own support requests"
  ON support_requests FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- FAQs are public (no RLS needed or allow all to read)
ALTER TABLE faqs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view FAQs"
  ON faqs FOR SELECT
  USING (true);
```

### Step 4: Insert Sample FAQs
```sql
INSERT INTO faqs (question, answer, category, "order") VALUES
(
  'How do I add a medication?',
  'Go to Account > Medications and tap the + button. Fill in the medication name, dosage, frequency, and reason. Tap Add to save.',
  'Medications',
  1
),
(
  'How do I manage emergency contacts?',
  'Go to Account > Emergency Contacts. You can add, edit, or delete contacts. Emergency contacts will be notified in case of an emergency.',
  'Emergency',
  2
),
(
  'How do I change notification settings?',
  'Go to Account > Notifications. Toggle the switches to enable or disable different types of notifications. Tap Save Settings to apply changes.',
  'Notifications',
  3
),
(
  'Is my health data secure?',
  'Yes, all your health data is encrypted and stored securely. We comply with HIPAA and other health privacy regulations.',
  'Security',
  4
),
(
  'How do I contact support?',
  'Go to Account > Help & Support. You can submit a support request or find our contact information there.',
  'Support',
  5
);
```

---

## User Context Information

### How to View Additional User Context

#### 1. **User Profile Information**
Access user data through the `UserProvider`:
```dart
final userProvider = Provider.of<UserProvider>(context);
print('User ID: ${userProvider.userId}');
print('User Email: ${userProvider.userEmail}');
print('User Name: ${userProvider.userName}');
```

#### 2. **Current Authenticated User**
Get the current user from Supabase:
```dart
final user = Supabase.instance.client.auth.currentUser;
print('User ID: ${user?.id}');
print('Email: ${user?.email}');
```

#### 3. **Query User-Specific Data**
Fetch user data from Supabase:
```dart
final response = await Supabase.instance.client
  .from('medications')
  .select()
  .eq('user_id', userId);
```

#### 4. **User Metadata**
Access additional user metadata:
```dart
final user = Supabase.instance.client.auth.currentUser;
final metadata = user?.userMetadata;
print('Metadata: $metadata');
```

---

## Features Implemented

### ✅ Medications Page
- **Add Medications**: Users can add medications with dosage, frequency, and reason
- **View Medications**: Display all medications in a list
- **Delete Medications**: Remove medications from the list
- **Database**: Stores in `medications` table

### ✅ Notifications Page
- **Notification Preferences**: Toggle different notification types
- **Save Settings**: Store preferences in `notification_settings` table
- **Load Settings**: Retrieve saved preferences on page load

### ✅ Help & Support Page
- **FAQs**: Display frequently asked questions from database
- **Support Requests**: Submit support requests with category and message
- **Quick Actions**: Email and phone contact options

### ✅ Privacy Policy Page
- **Static Content**: Comprehensive privacy policy information
- **Last Updated**: Shows when policy was last updated

---

## API Endpoints Used

### Medications
- `GET /medications` - Fetch user medications
- `POST /medications` - Add new medication
- `DELETE /medications` - Delete medication

### Notification Settings
- `GET /notification_settings` - Fetch settings
- `UPSERT /notification_settings` - Save/update settings

### Support Requests
- `POST /support_requests` - Submit support request

### FAQs
- `GET /faqs` - Fetch all FAQs

---

## Error Handling

All pages include error handling for:
- Network failures
- Database errors
- Missing user authentication
- Invalid data

Errors are displayed to users via SnackBar notifications.

---

## Security Considerations

1. **Row Level Security (RLS)**: Enabled on all user-specific tables
2. **User Authentication**: All operations require authenticated user
3. **Data Encryption**: Supabase encrypts data in transit and at rest
4. **HIPAA Compliance**: Health data is treated with highest confidentiality

---

## Testing

To test the features:

1. **Medications**:
   - Navigate to Account > Medications
   - Add a medication
   - Verify it appears in the list
   - Delete it and verify removal

2. **Notifications**:
   - Navigate to Account > Notifications
   - Toggle settings
   - Click Save Settings
   - Refresh page to verify settings persist

3. **Help & Support**:
   - Navigate to Account > Help & Support
   - View FAQs
   - Submit a support request

4. **Privacy Policy**:
   - Navigate to Account > Privacy Policy
   - Verify content displays correctly

---

## Troubleshooting

### Issue: "Error loading medications"
**Solution**: Ensure user is authenticated and `user_id` is correctly set

### Issue: "Error saving settings"
**Solution**: Check that `notification_settings` table exists and RLS policies are correct

### Issue: "FAQs not loading"
**Solution**: Verify FAQs table has data and RLS policy allows public read access

---

## Future Enhancements

- [ ] Medication reminders with push notifications
- [ ] Appointment scheduling
- [ ] Health metrics tracking
- [ ] Doctor integration
- [ ] Prescription management
- [ ] Health report generation

---

## Support

For issues or questions, contact: support@eldercare.com
