# Project Memory

## Project Goal
Develop the Smart Diet Assistant, a Flutter-based mobile health platform for elderly Malaysians that uses Google Gemini AI for culturally tailored meal planning.

## Active Phase
Phase 4: Robust Partial Menu Control
1. **Robust Partial Regeneration**: Implemented forced merging logic in `GeminiService`. AI is now strictly instructed to COPY unchanged lines and REGENERATE only target meals.
2. **State Consistency**: `AppState` now preserves logging status for unchanged meals during partial updates.
3. **UX Refinement**: Verified swapped confirmation buttons (Yes/Left/Green, No/Right/Red).
4. **Logic Accuracy**: Separated AI prompt strategies for "Fresh Generation" vs "Forced Merging" to ensure 100% reliability.

## Blockers
None.

## Next Steps
1. Push to feature branch and wait for user review.
2. Merge into master if approved.

## Completed (Summary)
- Project analyzed and documented in `GEMINI.md`.
- Implemented Secure API Key Management (`.env`).
- Fixed Navigation Flow (Auto-login & Logout).
- Phase 2: Session Persistence & Meal Logging.
- Phase 3: Cuisine Customization (Malay, Chinese, Indian).

## Architecture Mapping
- UI: `lib/screens/`
- State: `lib/providers/app_state.dart`
- AI Service: `lib/services/gemini_service.dart`
- Data Model: `lib/models/user_profile.dart`
