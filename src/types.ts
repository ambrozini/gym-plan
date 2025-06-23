import type { Database, Tables, TablesInsert, TablesUpdate } from "./db/database.types";

// =============================================================================
// BASE ENTITY TYPES (from database schemas)
// =============================================================================

export type Profile = Tables<{ schema: "profile" }, "profiles">;
export type Exercise = Tables<{ schema: "exercise_library" }, "exercises">;
export type Plan = Tables<{ schema: "plan_management" }, "plans">;

export type ProfileInsert = TablesInsert<{ schema: "profile" }, "profiles">;
export type ProfileUpdate = TablesUpdate<{ schema: "profile" }, "profiles">;
export type PlanInsert = TablesInsert<{ schema: "plan_management" }, "plans">;
export type PlanUpdate = TablesUpdate<{ schema: "plan_management" }, "plans">;

// =============================================================================
// TRAINING PLAN STRUCTURE TYPES (based on training-plan.json schema)
// =============================================================================

/**
 * Exercise within a training slot
 */
export interface TrainingExercise {
  exerciseId: string;
  sets: number;
  repetitions: number;
  restSeconds: number;
  tempo: Tempo;
  exerciseNotes: string;
}

/**
 * Training slot containing exercises
 */
export interface TrainingSlot {
  slotNotes: string;
  exercises: TrainingExercise[];
}

/**
 * Training day containing slots
 */
export interface TrainingDay {
  label: string;
  notes: string;
  slots: TrainingSlot[];
}

/**
 * Complete training plan structure
 */
export interface TrainingPlan {
  trainingDays: TrainingDay[];
}

// =============================================================================
// PROFILE DTOs AND COMMANDS
// =============================================================================

/**
 * Profile DTO for GET /profiles/me
 * Returns complete profile information for authenticated user
 */
export type ProfileDto = Profile;

/**
 * Command for POST /profiles
 * Creates new profile, excludes system-managed fields
 */
export type ProfileCreateCommand = Omit<ProfileInsert, "id" | "owner_id" | "created_at" | "updated_at" | "deleted_at">;

/**
 * Command for PATCH /profiles/me
 * Updates existing profile, all fields optional
 */
export type ProfileUpdateCommand = Omit<ProfileUpdate, "id" | "owner_id" | "created_at" | "updated_at" | "deleted_at">;

// =============================================================================
// EXERCISE DTOs
// =============================================================================

/**
 * Exercise DTO for GET /exercises/:id
 * Returns minimal exercise information for public access
 */
export type ExerciseDto = Pick<Exercise, "id" | "name" | "slug">;

// =============================================================================
// PLAN GENERATION DTOs AND COMMANDS
// =============================================================================

/**
 * Command for POST /plan-generations
 * Generates training plan with optional profile overrides
 */
export interface PlanGenerationCommand {
  override_frequency?: number; // days per week
  override_session_length?: string;
  override_primary_goal?: string;
  // Additional override fields can be added here as needed
}

/**
 * Response DTO for plan generation
 * Contains generated training plan structure
 */
export type PlanGenerationDto = TrainingPlan;

/**
 * Response DTO for PATCH /plan-generations/accept
 * Confirms acceptance of generated plan
 */
export interface PlanGenerationAcceptResponse {
  status: "accepted";
  trainingDays: TrainingDay[];
}

/**
 * Command for DELETE /plan-generations
 * Rejects generated plan with optional reason
 */
export interface PlanGenerationRejectCommand {
  reason?: string;
}

// =============================================================================
// PLAN MANAGEMENT DTOs AND COMMANDS
// =============================================================================

/**
 * Plan DTO for GET /plans/:id and plan listings
 * Excludes internal fields like owner_id and deleted_at
 */
export type PlanDto = Omit<Plan, "owner_id" | "deleted_at">;

/**
 * Response DTO for GET /plans
 * Paginated list of user's plans
 */
export interface PlansListDto {
  data: PlanDto[];
  total: number;
  limit: number;
  offset: number;
}

/**
 * Command for POST /plans
 * Creates new plan from accepted draft
 */
export type PlanCreateCommand = Omit<PlanInsert, "id" | "owner_id" | "created_at" | "updated_at" | "deleted_at">;

/**
 * Command for PUT /plans/:id
 * Updates existing plan
 */
export type PlanUpdateCommand = Omit<PlanUpdate, "id" | "owner_id" | "created_at" | "updated_at" | "deleted_at">;

// =============================================================================
// QUERY PARAMETERS AND FILTERS
// =============================================================================

/**
 * Query parameters for GET /plans
 */
export interface PlansQueryParams {
  sort?: "created_at" | "updated_at";
  limit?: number;
  offset?: number;
}

// =============================================================================
// ERROR AND VALIDATION TYPES
// =============================================================================

/**
 * Standard API error response structure
 */
export interface ApiError {
  message: string;
  details?: {
    field: string;
    message: string;
  }[];
}

/**
 * Validation constraints for training plan
 */
export interface TrainingPlanConstraints {
  maxTrainingDays: 100;
  maxLabelLength: 150;
  maxNotesLength: 500;
  maxPlansPerUser: 10;
  tempoPattern: RegExp; // /^[0-9X]{4}$/
}

// =============================================================================
// UTILITY TYPES
// =============================================================================

/**
 * Database schema names for type safety
 */
export type DatabaseSchema = keyof Database;

/**
 * Available equipment options (based on profile.available_equipment)
 */
export type EquipmentType = string; // Could be refined to specific enum values

/**
 * Experience levels (based on profile.experience_level)
 */
export type ExperienceLevel = "beginner" | "intermediate" | "advanced";

/**
 * Primary goals (based on profile.primary_goal)
 */
export type PrimaryGoal = "strength" | "muscle_building" | "endurance" | "weight_loss" | "general_fitness";

/**
 * Sex options (based on profile.sex)
 */
export type Sex = "male" | "female" | "other";

/**
 * Session length options (based on profile.session_length)
 */
export type SessionLength = "30min" | "45min" | "60min" | "90min" | "120min";

type TempoUnit = 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | "X";

export type Tempo = `${TempoUnit}${TempoUnit}${TempoUnit}${TempoUnit}`;
