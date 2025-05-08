## Database Schema - Plan management

### 1. List of tables with their columns, data types, and constraints

#### `plan_management.plans`
| Column          | Data Type     | Constraints                                                                                         |
| --------------- | --------------| --------------------------------------------------------------------------------------------------- |
| `id`            | UUID           | PRIMARY KEY, DEFAULT `gen_random_uuid()`                                                            |
| `owner_id`      | UUID           | NOT NULL                                                            |
| `title`         | TEXT           | NULLABLE                                                                                         |
| `training_days` | JSONB          | NOT NULL<br>CHECK `jsonb_typeof(training_days) = 'array'`<br>CHECK `jsonb_array_length(training_days) <= 100` |
| `created_at`    | TIMESTAMPTZ    | NOT NULL, DEFAULT `now()`                                                                           |
| `updated_at`    | TIMESTAMPTZ    | NOT NULL, DEFAULT `now()`                                                                           |
| `deleted_at`    | TIMESTAMPTZ    | NULLABLE                                                                                            |

**Trigger to set timestamps**
```sql
CREATE FUNCTION plan_management.set_timestamp() RETURNS trigger AS $$
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
  ON plan_management.plans
  FOR EACH ROW
  EXECUTE FUNCTION plan_management.set_timestamp();
```

### 2. Relationships between tables


### 3. Indexes
```sql
CREATE INDEX idx_plans_owner_active
  ON plan_management.plans(owner_id)
  WHERE deleted_at IS NULL;

CREATE INDEX idx_plans_owner_updated_at
  ON plan_management.plans(owner_id, updated_at DESC);
```

### 4. PostgreSQL Row-Level Security (RLS) policies
```sql
ALTER TABLE plan_management.plans ENABLE ROW LEVEL SECURITY;

-- SELECT: only active plans of the owner
CREATE POLICY select_own_plans
  ON plan_management.plans
  FOR SELECT
  USING (owner_id = auth.uid() AND deleted_at IS NULL);

-- INSERT: only with owner_id = auth.uid()
CREATE POLICY insert_own_plans
  ON plan_management.plans
  FOR INSERT
  WITH CHECK (owner_id = auth.uid());

-- UPDATE: only active plans of the owner
CREATE POLICY update_own_plans
  ON plan_management.plans
  FOR UPDATE
  USING (owner_id = auth.uid() AND deleted_at IS NULL)
  WITH CHECK (owner_id = auth.uid());

-- DELETE: blocked
CREATE POLICY deny_delete
  ON plan_management.plans
  FOR DELETE
  USING (false);
```

### 5. Additional notes and explanations
- **Soft-delete**: deleting a plan is handled by setting `deleted_at`; no physical DELETE operation.
- **No status column**: lifecycle (draft/accepted/rejected) is tracked in the PlanGeneration context; only active/deleted status is maintained in `plans`.
- **Limit of active plans (<= 10), same with training days object (limit of exercises, slots)**: enforced at the application layer.
- **Full JSON structure validation** is handled by the application using a `training-plan.json` schema (draft-2020-12).
- **Schema-per-context** according to ADR-0001: the table exists in the `plan_management` schema, without foreign keys to other contexts. Columns owner_id is a indirect reference to auth.users(id) as we cannot have foreign keys between different schemas

## Database Schema - Exercise Library Context

### 1. List of tables with their columns, data types, and constraints

#### `exercise_library.exercise`
| Column               | Data Type      | Constraints                                                                        |
| -------------------- | -------------- | ---------------------------------------------------------------------------------- |
| `id`                 | UUID           | PRIMARY KEY, DEFAULT `gen_random_uuid()`                                           |
| `name`               | VARCHAR(100)   | NOT NULL, UNIQUE                                                                   |
| `movementComplexity` | TEXT           | NULLABLE                                                                           |
| `symmetry`           | TEXT           | NULLABLE                                                                           |
| `category`           | TEXT           | NULLABLE                                                                           |
| `primaryMuscles`     | TEXT[]         | NOT NULL, CHECK `cardinality(primaryMuscles) > 0`                                  |
| `secondaryMuscles`   | TEXT[]         | NULLABLE                                                                           |
| `equipment`          | TEXT[]         | NULLABLE                                                                           |
| `rep_min`            | INT            | NULLABLE, CHECK `rep_min > 1`                                                      |
| `rep_max`            | INT            | NULLABLE, CHECK `rep_max <= 100`                                                   |
| `defaultTempo`       | TEXT           | NULLABLE, CHECK `defaultTempo IS NULL OR defaultTempo ~ '^((\d)|X){4}$'`           |
| `description`        | VARCHAR(500)   | NOT NULL                                                                           |
| `instructions`       | VARCHAR(500)   | NULLABLE                                                                           |
| `contraindications`  | VARCHAR(500)   | NULLABLE                                                                           |
| `created_at`         | TIMESTAMPTZ    | NOT NULL, DEFAULT `now()`                                                          |
| `updated_at`         | TIMESTAMPTZ    | NOT NULL, DEFAULT `now()`                                                          |

**Trigger to set timestamps**
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
  ON exercise_library.exercise
  FOR EACH ROW
  EXECUTE FUNCTION exercise_library.set_timestamp();
```

### 2. Relationships between tables

For the MVP, the `exercise` table in the `exercise_library` schema does not have relationships with other tables.

### 3. Indexes
```sql
-- Unique index on the name column (already enforced by the UNIQUE constraint)
```

### 4. PostgreSQL Row-Level Security (RLS) policies
```sql
ALTER TABLE exercise_library.exercise ENABLE ROW LEVEL SECURITY;

-- SELECT: available to all roles
CREATE POLICY select_all_exercises
  ON exercise_library.exercise
  FOR SELECT
  USING (true);

-- INSERT/UPDATE/DELETE: blocked for regular users
CREATE POLICY deny_insert
  ON exercise_library.exercise
  FOR INSERT
  USING (false);

CREATE POLICY deny_update
  ON exercise_library.exercise
  FOR UPDATE
  USING (false);

CREATE POLICY deny_delete
  ON exercise_library.exercise
  FOR DELETE
  USING (false);
```

### 5. Additional notes and explanations
- **Static content**: The exercise library is pre-populated with static content and not modifiable by users in the MVP.
- **Case sensitivity**: Exercise names are unique and case-sensitive.
- **Column naming convention**: Exercise library uses camelCase for column names.
- **Array validation**: The `primaryMuscles` array must contain at least one element.
- **Schema-per-context**: According to ADR-0001, this table exists in its own schema without foreign keys to other contexts.
- **Tempo format**: The `defaultTempo` field follows a 4-character format (digits or 'X') representing exercise phases.

