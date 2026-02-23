# Supabase Setup

This project uses Supabase Auth + Postgres for account-related features.

## 1. Required `dart-define` values

Use these when running the app:

```bash
flutter run --dart-define=SUPABASE_URL=<your-url> --dart-define=SUPABASE_ANON_KEY=<your-anon-key>
```

## 2. Create tables

Run in Supabase SQL Editor:

```sql
create table if not exists medications (
  id bigint primary key generated always as identity,
  user_id uuid not null references auth.users(id) on delete cascade,
  name varchar(255) not null,
  dosage varchar(100) not null,
  frequency varchar(100) not null,
  reason text,
  start_date timestamptz default now(),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists emergency_contacts (
  id bigint primary key generated always as identity,
  user_id uuid not null references auth.users(id) on delete cascade,
  name varchar(255) not null,
  phone varchar(20) not null,
  relationship varchar(100) not null,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists notification_settings (
  id bigint primary key generated always as identity,
  user_id uuid not null unique references auth.users(id) on delete cascade,
  email_notifications boolean default true,
  push_notifications boolean default true,
  medication_reminders boolean default true,
  appointment_reminders boolean default true,
  emergency_alerts boolean default true,
  health_updates boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists support_requests (
  id bigint primary key generated always as identity,
  user_id uuid not null references auth.users(id) on delete cascade,
  subject varchar(255) not null,
  message text not null,
  category varchar(100),
  status varchar(50) default 'open',
  response text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists faqs (
  id bigint primary key generated always as identity,
  question varchar(500) not null,
  answer text not null,
  category varchar(100),
  "order" int default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
```

## 3. Enable RLS

```sql
alter table medications enable row level security;
alter table emergency_contacts enable row level security;
alter table notification_settings enable row level security;
alter table support_requests enable row level security;
alter table faqs enable row level security;
```

## 4. Add policies

```sql
create policy "medications_select_own" on medications for select using (auth.uid() = user_id);
create policy "medications_insert_own" on medications for insert with check (auth.uid() = user_id);
create policy "medications_update_own" on medications for update using (auth.uid() = user_id);
create policy "medications_delete_own" on medications for delete using (auth.uid() = user_id);

create policy "contacts_select_own" on emergency_contacts for select using (auth.uid() = user_id);
create policy "contacts_insert_own" on emergency_contacts for insert with check (auth.uid() = user_id);
create policy "contacts_update_own" on emergency_contacts for update using (auth.uid() = user_id);
create policy "contacts_delete_own" on emergency_contacts for delete using (auth.uid() = user_id);

create policy "notification_select_own" on notification_settings for select using (auth.uid() = user_id);
create policy "notification_insert_own" on notification_settings for insert with check (auth.uid() = user_id);
create policy "notification_update_own" on notification_settings for update using (auth.uid() = user_id);

create policy "support_select_own" on support_requests for select using (auth.uid() = user_id);
create policy "support_insert_own" on support_requests for insert with check (auth.uid() = user_id);

create policy "faqs_public_read" on faqs for select using (true);
```

## 5. Optional: FAQ seed

```sql
insert into faqs(question, answer, category, "order")
values
('How do I add a medication?', 'Go to Account > Medications and tap +.', 'Medications', 1),
('How do I manage emergency contacts?', 'Go to Account > Emergency Contacts.', 'Emergency', 2)
on conflict do nothing;
```
