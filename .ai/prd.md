# Product Requirements Document (PRD) - GymPlan

## 1. Product Overview
GymPlan is a web application in MVP version designed for beginners and intermediate users who want to start strength training but lack advanced knowledge in creating personalized training plans. The application allows users to create an account, fill out a detailed profile, generate a training plan based on the provided data, and modify it. In the MVP, we focus on basic functionalities with clear limitations – advanced progress tracking, extensive analysis, or expanding the exercise database are part of future iterations.

## 2. User Problem
Users, especially beginners and intermediates, face difficulties in creating training plans on their own. Manually developing a list of exercises, selecting weights, the number of sets and repetitions, and adjusting the plan to training goals and health limitations is time-consuming and requires specialized knowledge. GymPlan aims to solve this problem by automating the process of generating a training plan based on user data, significantly simplifying the process of starting workouts.

## 3. Functional Requirements
1. User Account System
   - Registration using an email address and password.
   - Login, allowing secure access to saved data and plans.

2. User Profile
   - A form where the user provides long-term personal data:
     - Age, sex, height, weight
     - Training experience
     - Health limitations/injuries
   - Default generation preferences:
     - Primary training goal (muscle building, reduction, strength increase, fitness improvement)
     - Available equipment (home gym, professional gym, dumbbells, no equipment)
     - Preferred training frequency (days per week)
     - Preferred session length
   - Profile data exposed as an Open-Host Service that can be queried by other contexts.
   - No profile snapshots stored in MVP.

3. Exercise Library
   - A predefined, lightweight exercise repository implemented as a minimalist domain in PostgreSQL.
   - Consists of a dedicated `exercise_library` schema containing a table of exercises with columns: `id`, `name`, `slug`.
   - Each exercise record is uniquely identified by `id` and maintains a canonical `slug` for consistency.
   - The Plan Generation module accesses the library, ensuring deduplication and data consistency.
   - Training plans store only the `exerciseId` foreign key, rather than duplicating exercise details in their JSON payload.

4. Embedded Training Rules
   - The training rules logic is integrated within the Plan Generation module.
   - Provides guidelines for sets, repetitions, rest periods, and exercise selection using a static and generic implementation.
   - This embedded approach simplifies the MVP and is designed for future extraction into a dedicated context.

5. Generating a Training Plan
   - A form generating a plan based on profile data and generation parameters
   - Utilizing predefined training rules.
   - Creating plan based on exercise library.
   - Plans go through lifecycle states: draft (initially generated), accepted (approved by user), or rejected (discarded by user).
   - Rejected plans will not be deleted from the system, but saved with rejection reason and not shown on the users plan list.

6. Modification and Acceptance of the Plan
   - The user can edit the generated plan – adding or removing exercises, changing the number of sets, repetitions, and weights.
   - Ability to add personal notes at different levels (day, slot, exercise) and save the final version of the plan.
   - The accepted plan is assigned to the account and is available for later editing.
   - The system tracks plan acceptance status for auto-generated plans.

7. Managing Training Plans
   - The user can have multiple training plans (up to 10 per user) without a clear distinction of which plan is "active."
   - No versioning mechanism – each edit overwrites the previous version.
   - No events emitted for plan edit/delete operations.
   - Lifecycle states (active, deleted) is internal and indepentend from auto-generated plans.

8. Additional Requirements
   - A reminder message for the user about the need to consult a doctor in case of health doubts.
   - Simple data validation (minimum and maximum values) on both the front-end and back-end.
   - Testing mechanisms – both manual and automated.

## 3.1 Training Plan Data Structure
The structure of a training plan follows a hierarchical organization to ensure flexibility and extensibility.

1. **Training Plan**
   - Contains a collection of training days.
   - `trainingDays: TrainingDay[]`

2. **Training Day**
   - Represents a single workout session.
   - `notes?: string` — Optional general notes for the day (e.g., "Focus on technique", "Lower body day").
   - `slots: TrainingSlot[]` — A list of training slots to be performed during the day.

3. **Training Slot**
   - Represents a group of exercises performed sequentially.
   - `exercises: ExerciseEntry[]` — One or more exercises performed in sequence.
   - `slotNotes?: string` — Optional notes for the entire slot (e.g., "Superset - minimal rest between exercises").

4. **Exercise Entry**
   - Represents a specific exercise with its parameters.
   - `exerciseId: string` — Reference to the exercise in the library.
   - `sets: number` — Number of sets to perform.
   - `repetitions: number` — Number of repetitions per set.
   - `tempo: string` — Execution tempo in standard format (e.g., "3010" = 3s eccentric, 0s pause, 1s concentric, 0s pause).
   - `restSeconds: number` — Rest time after completing all sets of this exercise (in seconds).
   - `exerciseNotes?: string` — Optional specific notes for this exercise.

Key Design Principles:
- No distinction between types of slots (e.g., supersets, circuits) - instead, a slot with multiple exercises is treated as exercises to be performed sequentially.
- Notes can be added at three levels: day, slot, and individual exercise.
- The structure is intentionally simple for MVP but allows for future extensions without breaking changes.

Usage Patterns:
- A slot with one exercise = standard isolated exercise.
- A slot with two exercises = typically a superset.
- A slot with three or more exercises = typically a circuit.

This data structure ensures consistency and predictability while supporting both simple and complex training plans.

## 4. Product Boundaries
In the MVP, the following functionalities are excluded:
- Advanced tracking of training progress (reporting completed sets, weights, dynamic plan updates).
- Extensive analysis, charts, and progress monitoring (e.g., tracking user weight).
- An advanced admin panel for editing the exercise database by users.
- Sending and analyzing photos or videos (verification of exercise technique by AI).
- Detailed medical warnings and recommendations, beyond simple descriptions.
- Social functionalities (sharing plans, comments).
- Plan versioning and history tracking.
- Coach roles and permissions.
- Integration between Training Rules and specific exercise categories.
- Profile snapshots or historical profile data.

Technological boundaries (choice of frameworks, development schedule) and the scope of tests remain to be determined in subsequent phases of the project.

## 5. User Stories

### US-001
- Title: Account Registration
- Description: As a new user, I want to be able to register an account using an email address and password so that I can store my data and training plans.
- Acceptance Criteria:
  - The user must be able to register an account through the registration form.
  - The email field must be validated for correct format.
  - The password field must meet minimum requirements (e.g., length, complexity).
  - After registration, the user receives confirmation of account creation.

### US-002
- Title: Logging into the System
- Description: As a registered user, I want to be able to log into the application using an email address and password to access my training plans.
- Acceptance Criteria:
  - The user can log in through the login form.
  - The system checks the correctness of the data and grants access to the account.
  - In case of incorrect data, the user receives a message about incorrect login data.

### US-003
- Title: Completing the User Profile
- Description: As a user, I want to complete my profile with personal data and default training preferences so that future training plans can be tailored to my needs.
- Acceptance Criteria:
  - The profile form contains fields for personal data (age, sex, height, weight, experience, limitations).
  - The profile includes default generation preferences (goals, equipment, frequency, session length).
  - The user can save or edit the entered data.
  - Profile data is validated for correctness and value range.

### US-004
- Title: Generating a Training Plan
- Description: As a user, I want to generate a training plan based on the completed profile to obtain a personalized workout routine.
- Acceptance Criteria:
  - User can provide training preferences defaulted from profile data, but can be overriden
  - After clicking the "Generate Plan" button, the system uses data from the profile, the exercise database, and training rules to create the plan.
  - The generated plan includes training days with slots containing exercises, along with the recommended number of sets, repetitions, tempo, rest times, and optional notes.
  - The plan is initially created in a "draft" state.

### US-005
- Title: Reviewing and Editing the Training Plan
- Description: As a user, I want to be able to review the generated training plan and make changes to tailor it to my individual preferences.
- Acceptance Criteria:
  - The user can see the detailed training plan after it has been generated.
  - The interface allows editing: adding or removing exercises, changing the number of sets, repetitions, tempo, and rest times.
  - The user can add or edit notes at the day, slot, or exercise level.
  - After editing, the user can approve the modified plan, which will be saved in the system as "accepted."
  - The user can also reject the plan, which will mark it as "rejected" and remove it from active plans.

### US-006
- Title: Managing Saved Training Plans
- Description: As a user, I want to be able to view and edit my saved training plans.
- Acceptance Criteria:
  - The user sees a list of their training plans (up to 10 plans).
  - Each plan can be opened, viewed, and edited.
  - Rejected plans are not shown in the plan list.
  - No versioning mechanism – each edit overwrites the previous version.

### US-007
- Title: Information on the Need for Medical Consultation
- Description: As a user, I want to be informed about the need for a medical consultation in case of health doubts so that I can make informed decisions about training intensity.
- Acceptance Criteria:
  - When viewing generated plan there is a message visible.

## 6. Success Metrics
1. Generating and Accepting Plans
   - At least 75% of generated plans must be modified and then approved by users.
2. Active Use of the Application
   - 70% of registered users use the plan generation feature in the first month after registration.
3. User Satisfaction
   - Positive feedback regarding the intuitiveness of the interface and the adequacy of the proposed training plans.
4. Stability and Security
   - Reliable login, user data protection, and correct validation of entered information.