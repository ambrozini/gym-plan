# ADR 0001 — **Data Model: Schema‑per‑Context in Supabase**

**Date:** 2025‑04‑26
**Status:** Accepted
**Decision Makers:** GymPlan Core Team
**Contributors:** Szymon Ambroziak, ChatGPT (AI assistant)

---

## 1. Context

GymPlan (MVP) is based on a modular architecture with clearly separated **bounded contexts**: *Profile*, *Exercise Library*, *Training Rules*, *Plan Generation*, and *Plan Management*.

We aim to:

* Minimize coupling between contexts (no foreign keys across contexts).
* Allow independent development and scaling of modules.
* Keep the MVP simple, fast to deliver, and cost-effective.

The backend uses **Supabase**, which provides a managed PostgreSQL database and an API layer.

## 2. Decision

We will use the **schema‑per‑context** approach within a **single Supabase project**.

* Each bounded context will have its own dedicated PostgreSQL schema.
* Contexts will not reference each other's tables via foreign keys.
* Supabase "Exposed Schemas" settings will be configured to allow access to non‑`public` schemas via APIs.
* RLS (Row-Level Security) policies will be applied independently in each schema.

Schemas:

* `profile`
* `exercise_library`
* `training_rules`
* `plan_generation`
* `plan_management`

We will enforce soft boundaries:

* No cross‑schema JOINs allowed.
* Communication between contexts (if needed) will happen via APIs or materialized views.

This approach aligns with the modular monolith philosophy: fast MVP delivery with a clear path to split contexts into separate services if needed in future iterations.

## 3. Alternatives Considered

### a) Separate Database per Context

* **Pros:** Perfect isolation, independent scaling.
* **Cons:** Higher operational costs (each Supabase project = separate cluster), complex deployments, additional Auth/Edge function integration required.

### b) Single Schema (Public)

* **Pros:** Simplest setup.
* **Cons:** High risk of accidental coupling between contexts, harder future modularization.

## 4. Consequences

* **Positive:**

  * Clean modular structure.
  * Low operating costs.
  * Easier evolution to microservices architecture if necessary.

* **Negative:**

  * Requires discipline during development to respect schema boundaries.
  * Coordinated migrations needed when multiple schemas are updated.

## 5. Migration Strategy

Migration scripts will be managed per schema.
In the CI pipeline, migrations will be executed sequentially with clear dependency ordering if required.
