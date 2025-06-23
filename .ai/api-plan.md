# REST API Plan

## 1. Resources
- User Authentication (`auth`) – Supabase Auth service (external)
- Profile (`profile.profiles`)
- Exercise (`exercise_library.exercises`)
- Training Plan (`plan_management.plans`)
- Plan Generation (transient draft, not persisted)

## 2. Endpoints

### 2.1 Authentication (via Supabase Auth)
(note: leveraging Supabase Auth; endpoints are handled by Supabase)
// TODO

### 2.2 Profile Service

All profile endpoints require `Authorization: Bearer <accessToken>`.

- GET `/profiles/me`
  - Description: Retrieve current user's profile
  - Response 200:
    ```json
    {
      "id": "uuid",
      "owner_id": "uuid",
      "age": number,
      "sex": string,
      "height_cm": number,
      "weight_kg": number,
      "experience_level": string,
      "limitations": string,
      "primary_goal": string,
      "available_equipment": string[],
      "session_length": string,
      "generation_params": object,
      "created_at": string,
      "updated_at": string
    }
    ```
  - Errors:
    - 404: No profile found
    - 401: Unauthorized

- POST `/profiles`
  - Description: Create user profile (only once)
  - Request:
    ```json
    {
      "age": number,
      "sex": string,
      "height_cm": number,
      "weight_kg": number,
      "experience_level": string,
      "limitations": string,
      "primary_goal": string,
      "available_equipment": string[],
      "session_length": string,
      "generation_params": object
    }
    ```
  - Response 201:
    - Body: profile object (as in GET)
  - Errors:
    - 400: validation error
    - 409: profile already exists
    - 401: Unauthorized

- PATCH `/profiles/me`
  - Description: Update existing profile
  - Request: any subset of profile fields
  - Response 200: updated profile
  - Errors:
    - 400: validation error
    - 404: profile not found
    - 401: Unauthorized

### 2.3 Exercise Library

Public, no auth required

- GET `/exercises/:id`
  - Description: Retrieve exercise by id
  - Response 200:
    ```json
    { "id": "uuid", "name": string, "slug": string }
    ```
  - Errors:
    - 404: Not found

### 2.4 Plan Generation (Draft)

Requires authentication

- POST `/plan-generations`
  - Description: Generate a new training plan draft based on user profile and overrides
  - Request:
    ```json
    {
      "override_frequency": number,      // optional days per week
      "override_session_length": string,  // optional session length
      "override_primary_goal": string,    // optional goal
      // additional override fields
    }
    ```
  - Response 200:
    ```json
    {
      "trainingDays": [
        {
          "label": string,
          "notes": string,
          "slots": [
            {
              "slotNotes": string,
              "exercises": [
                {
                  "exerciseId": "uuid",
                  "sets": number,
                  "repetitions": number,
                  "restSeconds": number,
                  "tempo": string,
                  "exerciseNotes": string
                }
              ]
            }
          ]
        }
      ]
    }
    ```
  - Errors:
    - 400: validation error (profile incomplete, invalid overrides)
    - 401: Unauthorized
    - 429: Rate limit exceeded (to prevent abuse)

- PATCH `/plan-generations/accept`
  - Description: Accept a generated training plan draft, marking it ready to be persisted as a plan
  - Request: empty (no body required)
  - Response 200:
    ```json
    {
      "status": "accepted",
      "trainingDays": [ ... ]
    }
    ```
  - Errors:
    - 400: No draft plan to accept
    - 401: Unauthorized

- DELETE `/plan-generations`
  - Description: Reject a generated training plan draft; optionally provide a rejection reason.
  - Request:
    ```json
    { "reason": "string" }
    ```
  - Response 204: no content
  - Errors:
    - 400: validation error
    - 401: Unauthorized

### 2.5 Plan Management (Accepted Plans)

Requires authentication

- GET `/plans`
  - Description: List accepted (active) plans for current user
  - Query Params:
    - `sort` (string, one of `created_at`, `updated_at`, default `updated_at`)
  - Response 200:
    ```json
    {
      "data": [
        { "id": "uuid", "title": string, "training_days": object, "created_at": string, "updated_at": string }
      ],
      "total": number,
      "limit": number,
      "offset": number
    }
    ```

- GET `/plans/:id`
  - Description: Retrieve a single plan
  - Response 200:
    ```json
    { "id": "uuid", "title": string, "training_days": object, "created_at": string, "updated_at": string }
    ```
  - Errors:
    - 404: not found
    - 401: Unauthorized

- POST `/plans`
  - Description: Accept and persist a draft training plan as an active plan
  - Request:
    ```json
    {
      "title": string,               // optional descriptive title
      "training_days": object        // validated against training-plan.json schema
    }
    ```
  - Response 201:
    - Body: created plan object
  - Errors:
    - 400: validation error (schema violation, plan count > 10)
    - 401: Unauthorized

- PUT `/plans/:id`
  - Description: Edit an existing plan
  - Request: the whole plan with updated fields
  - Response 200:
    - Body: updated plan object
  - Errors:
    - 400: validation error
    - 404: not found or deleted
    - 401: Unauthorized

- DELETE `/plans/:id`
  - Description: Soft-delete an active plan (reject or remove)
  - Response 204: no content
  - Errors:
    - 404: not found
    - 401: Unauthorized

## 3. Authentication & Authorization
- Use Supabase JWTs (`Authorization: Bearer <token>`) for user authentication
- RLS policies in PostgreSQL enforce per-user access (owner_id = auth.uid())
- Admin role (service_role) bypasses RLS for administrative tasks

## 4. Validation & Business Logic
- Profile:
  - `age`: integer within [10,120]
  - `sex`: one of [`male`,`female`,`other`]
  - `height_cm`,`weight_kg`: positive integers
  - Unique constraint: one profile per user
- Plan Generation:
  - Ensure profile exists and is complete before generating
  - Rate limit: max 5 generation requests per minute per user
- Training Plan JSON:
  - Validate against `training-plan.json` schema
  - `trainingDays` items <=100
  - Each `label` length 1–150
  - Each `notes`, `slotNotes`, `exerciseNotes` max 500 chars
  - Each exercise: `sets` >=1, `repetitions` >=1, `restSeconds` >=0, `tempo` matches `/^[0-9X]{4}$/`
  - `exerciseId` matches UUID pattern
- Plan Management:
  - Max 10 active plans per user (enforce in POST)
  - Soft-delete via `deleted_at`; default list endpoints filter out soft-deleted

## 5. Pagination, Filtering, Sorting
- Sorting on `/plans` by `created_at` or `updated_at`

## 6. Error Handling & Responses
- 400 Bad Request for validation errors (return array of error details)
- 401 Unauthorized for missing/invalid token
- 403 Forbidden for RLS violations
- 404 Not Found for missing resources
- 429 Too Many Requests for rate limiting
- 500 Internal Server Error for unexpected failures

## 7. Security & Performance
- Enforce RLS and JWT authentication
- Rate limiting on plan generation
- Utilize DB indexes:
  - `idx_plans_owner_active` for queries on `/plans`
  - `idx_exercises_slug` for `/exercises/:slug`
- JSONB validation at API layer before DB insert
- Soft-delete purging via scheduled job per GDPR 