# Product Requirements Document (PRD) - GymPlan

## 1. Product Overview
GymPlan is a web application in MVP version designed for beginners and intermediate users who want to start strength training but lack advanced knowledge in creating personalized training plans. The application allows users to create an account, fill out a detailed profile, generate a training plan based on the provided data, and modify it. In the MVP, we focus on basic functionalities with clear limitations – advanced progress tracking, extensive analysis, or expanding the exercise database are part of future iterations.

## 2. User Problem
Users, especially beginners and intermediates, face difficulties in creating training plans on their own. Manually developing a list of exercises, selecting weights, the number of sets and repetitions, and adjusting the plan to training goals and health limitations is time-consuming and requires specialized knowledge. GymPlan aims to solve this problem by automating the process of generating a training plan based on user data, significantly simplifying the process of starting workouts.

## 3. Functional Requirements
1. User Account System
   - Registration using an email address and password.
   - Login, allowing secure access to saved data and plans.

2. Expanded User Profile
   - A form where the user provides personal data (age, height, weight, gender, activity level).
   - Specification of training goals (muscle building, reduction, strength increase, fitness improvement).
   - Selection of experience level (beginner, intermediate, advanced).
   - Information about available equipment (home gym, professional gym, dumbbells, no equipment).
   - Optionally: entering health limitations (knee problems, back issues, other injuries).

3. Exercise Database
   - A predefined, static database of exercises covering several dozen of the most popular exercises.
   - Each exercise includes a name, a brief description of the execution technique, metadata (muscle groups, required equipment, health limitations), and possible tips.
   - The exercise database is static – there is no possibility for users or an admin panel to edit it.

4. Generating a Training Plan
   - A form generating a plan based on profile data, the choice of the number of training days (from 1 to 7), and session length (from 30 minutes to 2+ hours).
   - Utilizing predefined rules regarding the number of sets, repetitions, split schemes, and AI mechanisms to select exercises and suggest progression (e.g., "increase by 1 kg every week" or "add 1-2 repetitions").

5. Modification and Acceptance of the Plan
   - The user can edit the generated plan – adding or removing exercises, changing the number of sets, repetitions, and weights.
   - Ability to add personal notes and save the final version of the plan.
   - The accepted plan is assigned to the account and is available for later editing.

6. Managing Training Plans
   - The user can have multiple training plans without a clear distinction of which plan is "active."
   - No versioning mechanism – each edit overwrites the previous version.

7. Additional Requirements
   - A reminder message for the user about the need to consult a doctor in case of health doubts.
   - Simple data validation (minimum and maximum values) on both the front-end and back-end.
   - Testing mechanisms – both manual and automated.

## 4. Product Boundaries
In the MVP, the following functionalities are excluded:
- Advanced tracking of training progress (reporting completed sets, weights, dynamic plan updates).
- Extensive analysis, charts, and progress monitoring (e.g., tracking user weight).
- An advanced admin panel for editing the exercise database by users.
- Sending and analyzing photos or videos (verification of exercise technique by AI).
- Detailed medical warnings and recommendations, beyond simple descriptions.
- Social functionalities (sharing plans, comments).

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
- Description: As a user, I want to complete my profile with personal data (age, height, weight, gender, activity level), training goals, experience level, equipment information, and any health limitations so that the training plan is tailored to my needs.
- Acceptance Criteria:
  - The profile form contains mandatory and optional fields according to the requirements.
  - The user can save or edit the entered data.
  - Profile data is validated for correctness and value range.

### US-004
- Title: Generating a Training Plan
- Description: As a user, I want to generate a training plan based on the completed profile to obtain a personalized exercise plan.
- Acceptance Criteria:
  - The user can choose the number of training days per week (from 1 to 7) and specify the length of training sessions.
  - After clicking the "Generate Plan" button, the system uses data from the profile, the exercise database, and defined rules to create the plan.
  - The generated plan includes a list of exercises assigned to the selected days, along with the recommended number of sets, repetitions, and suggested weights.

### US-005
- Title: Reviewing and Editing the Training Plan
- Description: As a user, I want to be able to review the generated training plan and make changes to tailor it to my individual preferences.
- Acceptance Criteria:
  - The user can see the detailed training plan after it has been generated.
  - The interface allows editing: adding or removing exercises, changing the number of sets, repetitions, and weights.
  - After editing, the user can approve the modified plan, which will be saved in the system.

### US-006
- Title: Managing Saved Training Plans
- Description: As a user, I want to be able to view and edit saved training plans so that I have access to all my training proposals in one place.
- Acceptance Criteria:
  - The user sees a list of saved training plans assigned to their account.
  - Each saved plan can be opened, viewed, and edited.
  - No versioning mechanism – each edit overwrites the previous version of the plan.

### US-007
- Title: Information on the Need for Medical Consultation
- Description: As a user, I want to be informed about the need for a medical consultation in case of health doubts so that I can make informed decisions about training intensity.
- Acceptance Criteria:
  - During registration and while completing the profile, a warning message appears reminding about the need for a medical consultation in case of doubts.
  - The message is visible and cannot be ignored during the first use of the plan generation function.

## 6. Success Metrics
1. Generating and Accepting Plans
   - At least 75% of generated plans must be modified and then approved by users.
2. Active Use of the Application
   - 70% of registered users use the plan generation feature in the first month after registration.
3. User Satisfaction
   - Positive feedback regarding the intuitiveness of the interface and the adequacy of the proposed training plans.
4. Stability and Security
   - Reliable login, user data protection, and correct validation of entered information.