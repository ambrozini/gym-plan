# GymPlan – Domain Discovery Summary (MVP)

## 🧾 Summary

This document captures key decisions and open questions from our domain modeling workshop for the MVP of **GymPlan** – a training plan generator for strength trainees. The MVP focuses on allowing users to create personalized training plans based on profile data, predefined rules, and a static exercise library. The system is designed with modular, bounded contexts and lightweight integrations to simplify early development and support future growth. Particular care has been taken to separate concerns like plan lifecycle, profile management, and training logic into independent services.

> **Updated May 2025**: As per ADR-0002, the Training Rules context has been temporarily embedded within Plan Generation for the initial MVP, to simplify development and accelerate time-to-market.

---

## ✅ Decisions

### Actors & Roles
- **Primary actor**: Trainee.
- Coach role deferred to future iterations.

### User Profile
- Stores long-term personal and health data:
  - Age
  - Sex
  - Height
  - Weight
  - Training Experience
  - Injuries / Limitations
- Also stores **default generation preferences**:
  - Primary Training Goal
  - Available Equipment
  - Training Days / Week
  - Preferred Session Length
- **Profile** is a separate bounded context.
- **Open-Host Service**, synchronously queried by Plan Generation.
- No profile snapshots stored in MVP.

### Exercise Library
- Separate bounded context.
- Static catalog of supported exercises.
- Metadata includes muscles, equipment, etc.
- **Open-Host Service**, queried synchronously.
- Static contents for MVP.

### Training Rules Logic (Embedded in Plan Generation)
- Basic training rule logic embedded directly in Plan Generation for MVP.
- Will be extracted to a separate context in future iterations.
- Static and generic rule implementation for now.
- Designed with clean interfaces to facilitate future extraction.

### Plan Generation
- Separate bounded context.
- Accepts **PlanRequested** trigger.
- Synchronously calls: Profile, Exercise Library.
- Incorporates embedded training rule logic.
- Aggregates:
  - Static profile data
  - Default preferences (can be overridden)
  - Exercise Library
- Constructs a **`PlanRequest`** structure:
  - Full specification for plan generation
  - Can override defaults from profile
- Creates plans via **Plan Management** and tracks lifecycle in its own entity `PlanGeneration`.
- Domain events:
  - `PlanRequested`
  - `PlanAccepted`
- `PlanGeneration` stores:
  - Plan ID (reference)
  - Status: draft, accepted, rejected
  - Timestamps
  - Anonymized prompt (optional)
  - Rejection reason (optional)
- **Multiple plans per user allowed**, up to 10 per user.
- Rejected plans are saved as rejected with the reason and not shown for the user anymore.

### Plan Management
- Pure CRUD context, no lifecycle awareness.
- Synchronously called by Plan Generation.
- Stores finalized plans (even if user rejects later).
- Track simple lifecycle (Active or Deleted)
- Named **Plan Management**.

### Integration & Lifecycle
- All integrations are **synchronous** for MVP.
- No events emitted for plan edit/delete.
- No plan versioning in MVP.
- Only `PlanGeneration` tracks lifecycle.
- Lifecycle rules (draft, acceptance) apply only to auto-generated plans.

---

## ❓ Unresolved Questions

- When and how to introduce **Coach** roles and permissions?
- Future **versioning and history strategy** once tracking is added.
- What other services will consume the **Exercise Library**?
- When to extract the embedded training rules into a separate bounded context?
- Final **CreateDraft** contract between Plan Generation and Plan Management.

---

## 🗺️ Context Map (Mermaid)

```mermaid
graph TD

Trainee -->|fills| Profile
Trainee -->|requests plan| PlanGeneration

subgraph "Profile Context"
  Profile
end

subgraph "Exercise Library Context"
  ExerciseLibrary
end

subgraph "Plan Management Context"
  PlanManagement
end

subgraph "External LLM Service"
  LLM[Large Language Model]
end

subgraph "Plan Generation Context"
  PlanGeneration[API Gateway]
  DataAggregator[Data Aggregator]
  Generator[Plan Generator]
  TrainingRulesLogic[Embedded Training Rules]
  
  PlanGeneration --> DataAggregator
  DataAggregator --> Generator
  DataAggregator -->|fetches defaults| Profile
  DataAggregator -->|fetches data| ExerciseLibrary
  Generator -->|applies rules| TrainingRulesLogic
  Generator -->|creates plan| PlanManagement
  Generator -->|requests plan generation| LLM
  LLM -->|returns generated plan| Generator
end
