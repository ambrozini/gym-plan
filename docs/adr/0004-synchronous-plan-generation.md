# ADR 0004 — **Synchronous Plan Generation for MVP**

**Date:** 2025‑05‑10
**Status:** Accepted
**Decision Makers:** GymPlan Core Team
**Contributors:** Szymon Ambroziak, ChatGPT (AI assistant)

---

## 1. Context

GymPlan's Plan Generation context is responsible for creating personalized training plans based on user profiles and preferences. The generation process involves:

* Fetching user profile data
* Applying training rules
* Accessing the exercise library
* Creating a structured training plan

We need to decide on the interaction pattern between the user interface and the plan generation service for the MVP phase.

## 2. Decision

We will implement plan generation as a **synchronous process** in the MVP:

* The user interface will make a direct HTTP request to the plan generation endpoint
* The endpoint will process the request and return the complete plan in a single response
* No background jobs or message queues will be used
* The user will wait for the response in the UI

This approach aligns with our MVP goals:
* Simplified implementation
* Faster development cycle
* Reduced infrastructure complexity
* Direct error handling and response flow

## 3. Alternatives Considered

### a) Asynchronous Generation with Polling

* **Pros:** Better handling of long-running operations, improved scalability
* **Cons:** More complex implementation, additional infrastructure needed, more complex error handling

### b) WebSocket-based Progress Updates

* **Pros:** Real-time progress updates, better user experience
* **Cons:** Significant increase in implementation complexity, overkill for MVP

## 4. Consequences

* **Positive:**

  * Simple, straightforward implementation
  * Faster MVP delivery
  * Easier debugging and error tracking
  * No additional infrastructure required

* **Negative:**

  * User must wait for the entire generation process to complete
  * Potential timeout issues for slow connections
  * Limited scalability
  * No progress updates during generation

## 5. Future Considerations

This decision is explicitly temporary for the MVP phase. We anticipate moving to an asynchronous implementation in future iterations when:

* Generation times become noticeable
* User feedback indicates the need for progress updates
* We need to handle higher concurrent load
* We implement more complex generation algorithms

The future asynchronous implementation will likely involve:
* Background job processing
* Progress tracking
* Queue-based architecture 