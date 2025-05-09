## Exercise Library Context - Database Schema

### Table Structure

#### `exercise_library.exercises`
| Column          | Data Type     | Constraints                                                                                         |
| --------------- | --------------| --------------------------------------------------------------------------------------------------- |
| `id`            | UUID          | PRIMARY KEY, DEFAULT `gen_random_uuid()`                                                            |
| `name`          | TEXT          | NOT NULL, UNIQUE                                                                                    |
| `slug`          | TEXT          | NOT NULL, UNIQUE                                                                                    |
| `created_at`    | TIMESTAMPTZ   | NOT NULL, DEFAULT `now()`                                                                          |
| `updated_at`    | TIMESTAMPTZ   | NOT NULL, DEFAULT `now()`                                                                          |

### Triggers

**Timestamp Management**
```sql
CREATE FUNCTION exercise_library.set_timestamp() RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    NEW.created_at := now();
    NEW.updated_at := now();
  ELSIF TG_OP = 'UPDATE' THEN
    NEW.updated_at := now();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_timestamp
  BEFORE INSERT OR UPDATE
  ON exercise_library.exercises
  FOR EACH ROW
  EXECUTE FUNCTION exercise_library.set_timestamp();
```

### Indexes
```sql
CREATE INDEX idx_exercises_slug
  ON exercise_library.exercises(slug);
```

### Row Level Security (RLS) Policies
```sql
ALTER TABLE exercise_library.exercises ENABLE ROW LEVEL SECURITY;

-- SELECT: everyone can read exercises
CREATE POLICY select_exercises
  ON exercise_library.exercises
  FOR SELECT
  USING (true);

-- INSERT/UPDATE/DELETE: blocked for all users (admin-only operations)
CREATE POLICY deny_modifications
  ON exercise_library.exercises
  FOR ALL
  USING (false);
```

### Additional Notes
- **Minimalist Design**: Implemented as a lightweight domain in PostgreSQL with read-only access for regular users.
- **Admin Management**: Exercise data is managed through administrative operations only.
- **Schema-per-context**: According to ADR-0001 and ADR-0002, this context is kept minimal and independent.
- **Unique Constraints**: Both `name` and `slug` are unique to ensure data consistency.
- **Read-only Access**: Regular users can only read exercise data, modifications are restricted to administrative operations. 