# Profile Service Database Schema

1. Tables

### profile.profiles
| Column              | Type                         | Constraints                                        |
|---------------------|------------------------------|----------------------------------------------------|
| id                  | UUID                         | PRIMARY KEY DEFAULT gen_random_uuid()              |
| owner_id            | UUID                         | NOT NULL UNIQUE REFERENCES auth.users(id)          |
| age                 | INT                          |                                                    |
| sex                 | TEXT                         |                                                    |
| height_cm           | INT                          |                                                    |
| weight_kg           | INT                          |                                                    |
| experience_level    | TEXT                         |                                                    |
| limitations         | TEXT                         |                                                    |
| primary_goal        | TEXT                         |                                                    |
| available_equipment | TEXT[]                       |                                                    |
| session_length      | TEXT                         |                                                    |
| generation_params   | JSONB                        |                                                    |
| deleted_at          | TIMESTAMP WITH TIME ZONE     |                                                    |
| created_at          | TIMESTAMP WITH TIME ZONE     | NOT NULL DEFAULT now()                             |
| updated_at          | TIMESTAMP WITH TIME ZONE     | NOT NULL DEFAULT now()                             |


3. Indexes

- **PRIMARY KEY** on `id`
- **UNIQUE INDEX** on `owner_id`
- **BTREE INDEX** on `deleted_at` (to efficiently find soft-deleted records for purging)

4. Row-Level Security (RLS) Policies

```sql
-- Enable RLS
aLTER TABLE profile.profiles ENABLE ROW LEVEL SECURITY;

-- Allow profile owners to SELECT their active profiles
CREATE POLICY select_own_profiles ON profile.profiles
  FOR SELECT
  USING (auth.uid() = owner_id AND deleted_at IS NULL);

-- Allow service_role to SELECT all profiles (bypass soft-delete)
CREATE POLICY select_all_profiles_service ON profile.profiles
  FOR SELECT TO service_role
  USING (true);

-- Allow owners to INSERT their own profile data
CREATE POLICY insert_own_profile ON profile.profiles
  FOR INSERT
  WITH CHECK (auth.uid() = owner_id);

-- Allow owners to UPDATE their profiles (including soft-delete via deleted_at)
CREATE POLICY update_own_profile ON profile.profiles
  FOR UPDATE
  USING (auth.uid() = owner_id);
```

5. Additional Notes

- A trigger function `set_updated_at` should be created to automatically update `updated_at` on every row modification.
- Use `pg_cron`, `pgAgent`, or an external scheduler to PURGE records where `deleted_at < now() - interval '30 days'` in accordance with GDPR.
- Ensure the `pgcrypto` extension is enabled (`CREATE EXTENSION IF NOT EXISTS pgcrypto;`) for `gen_random_uuid()` support.
- Sensitive fields (e.g., date of birth) can be encrypted using `pgcrypto` if required by security policies.
- No additional analytical indexes or partitioning are added at this stage; monitor table growth and revisit as needed. 
- Column owner_id is a indirect reference to auth.users(id) as we cannot have foreign keys between different schemas 