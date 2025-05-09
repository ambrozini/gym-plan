## Plan Management Context - Database Schema

### Table Structure

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

### Triggers

**Timestamp Management**
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

### Indexes
```sql
CREATE INDEX idx_plans_owner_active
  ON plan_management.plans(owner_id)
  WHERE deleted_at IS NULL;

CREATE INDEX idx_plans_owner_updated_at
  ON plan_management.plans(owner_id, updated_at DESC);
```

### Row Level Security (RLS) Policies
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

### Additional Notes
- **Soft-delete**: deleting a plan is handled by setting `deleted_at`; no physical DELETE operation.
- **No status column**: lifecycle (draft/accepted/rejected) is tracked in the PlanGeneration context; only active/deleted status is maintained in `plans`.
- **Limit of active plans (<= 10), same with training days object (limit of exercises, slots)**: enforced at the application layer.
- **Full JSON structure validation** is handled by the application using a `training-plan.json` schema (draft-2020-12).
- **Schema-per-context** according to ADR-0001: the table exists in the `plan_management` schema, without foreign keys to other contexts. Columns owner_id is a indirect reference to auth.users(id) as we cannot have foreign keys between different schemas 