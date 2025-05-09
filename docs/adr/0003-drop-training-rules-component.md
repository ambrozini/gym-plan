# ADR 0003 — **Drop Training Rules Component in MVP**

**Date:** 2025-05-09
**Status:** Accepted
**Decision Makers:** GymPlan Core Team

---

## 1. Context

GymPlan MVP is designed with modular bounded contexts as outlined in ADR-0001. The original architecture included five contexts: *Profile*, *Exercise Library*, *Training Rules*, *Plan Generation*, and *Plan Management*.

After reviewing the implementation roadmap and timeline constraints, we need to simplify the MVP to focus on delivering core value quickly while maintaining architectural integrity.

## 2. Decision

We will **remove the Training Rules context** from the initial MVP implementation and embed the necessary training logic directly in the Plan Generation context.

Key aspects of this decision:

* Basic training rules will rely on model knowledge.
* The Plan Generation context will incorporate a simpler set of predefined rules rather than querying a separate Training Rules service.
* This training logic will still follow bounded context principles internally, remaining isolated in clearly defined service classes.
* We'll design the code to be easily extractable into a dedicated bounded context in future iterations.

## 3. Alternatives Considered

### a) Implement Training Rules as a Separate Context with Minimal Functionality

* **Pros:** Maintains the originally planned architecture, cleaner separation of concerns.
* **Cons:** Introduces additional development overhead, infrastructure complexity, and integration points without significant functional benefit in the MVP phase.

### b) Fully Merge Training Rules Logic into the LLM Prompt

* **Pros:** Simplifies development, offloads all training rules to the LLM service.
* **Cons:** Reduces control over training plan generation logic, makes rules less transparent, may lead to inconsistent results.

## 4. Consequences

* **Positive:**
  * Simplified architecture with fewer integration points for the MVP.
  * Faster time-to-market with reduced development effort.
  * Training logic remains conceptually separate, just not as a dedicated context.

* **Negative:**
  * Plan Generation context temporarily takes on more responsibility than ideal.
  * Future extraction of Training Rules will require refactoring.
  * Some duplication of concepts across contexts until proper extraction.

## 5. Implementation Strategy

1. Update the context map to reflect this change.
2. Implement essential training rules as internal service classes within Plan Generation.
3. Document the training rule logic to facilitate future extraction.
4. Ensure Plan Generation's LLM prompts incorporate essential training parameters.
5. Design with clean interfaces to minimize refactoring when extracting to a separate context.

## 6. Future Migration Path

In subsequent releases, we'll:

1. Identify all training rule logic in Plan Generation.
2. Extract these rules into a dedicated Training Rules context.
3. Establish proper communication patterns between contexts.
4. Enhance the dedicated Training Rules context with more advanced functionality (e.g., progression models, periodization strategies).

This approach allows us to deliver MVP functionality quickly while maintaining a clear path to the target architecture. 