# ADR 0002 — **Minimalist Exercise Library (MVP‑Light)**

**Date:** 2025-05-09
**Status:** Accepted
**Decision Makers:** GymPlan Core Team (Product Owner, Tech Lead, Architect)
**Contributors:** 

---

## 1. Context

The initial MVP design included a static Exercise Library. To reach market earlier we decided to miminimse this component. We still need unambiguous exercise identifiers to avoid data duplication and to allow seamless growth in the next release.

## 2. Decision

1. Create a lightweight domain schema `exercise_library` in the existing PostgreSQL monolith.
2. Inside that schema define a single table

   ```sql
   CREATE TABLE exercise_library.exercises (
     id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     name      TEXT NOT NULL,
     slug      TEXT NOT NULL UNIQUE,
     created_at TIMESTAMPTZ NOT NULL DEFAULT now()
   );
   ```
3. The **Plan Generation** module uses the *domain façade* `ExerciseLibraryFacade.createOrGetByName(name)`

   * If `slug` exists, it returns the existing `id`.
   * Otherwise it inserts a new row using `INSERT … ON CONFLICT(slug) DO NOTHING … RETURNING id`.
   * The façade lives inside the same monolith; no HTTP call is involved.
   * Only Plan Generation is authorised to create new records (guarded at service layer or via RLS).
4. Training Plans store only `exerciseId` (foreign key). They do **not** duplicate the exercise name in their JSON payload.
5. Data‑quality safeguards

   * Canonical `slug` is generated server‑side (lowercase, kebab‑case).
   * A curated list of \~400 canonical slugs seeds the table; new inserts are matched fuzzily.

## 3. Alternatives Considered

### a) Name‑only in JSON

* **Pros:** Fastest implementation approach.
* **Cons:** Would require a full data migration and heavy fuzzy‑matching later.

### b) Shadow table inside the Plan schema

* **Pros:** Simpler ACL.
* **Cons:** Violates *schema per bounded context* principle and complicates future extraction.

## 4. Consequences

### Positive

* Keeps Domain‑Driven design boundaries clean while remaining inside the monolith.
* Eliminates future Training Plan migrations; we can extend the table in place.
* Enables analytics on exercise popularity from day one.
* No network overhead thanks to the intra‑process façade.
* Seam for later microservice extraction: only the façade's adapter changes.

### Negative / Risks

* Need to implement the façade and guards (≈ 0.5 day).
* Risk of trash data - we accept it for now

## 5. Next Steps

1. Implement the table and façade; add unit tests for conflict handling.
2. Seed canonical slug list and simple fuzzy matcher.
3. Update PRD, context map and ER diagrams to make sure it keeps minimal version of our plan
