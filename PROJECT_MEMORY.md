# Project Memory

## Project Goal
Develop the Smart Diet Assistant, a Flutter-based mobile health platform for elderly Malaysians that uses Google Gemini AI for culturally tailored meal planning.

## Active Phase
Phase 7: Chat, Goals & UI Refinement (Final Polish)
1. **Goal-Based Profiles**: Implemented "Primary Health Goal" selection (Weight Loss, Muscle Gain, etc.) during onboarding. AI now tailors advice to these goals.
2. **AI Nutritionist Chat**: Overhauled the `ChatTab` to be fully functional. Users can now have persistent conversations with an AI expert.
3. **AppBar UI Fix**: Restored the "Change Menu" button to its high-visibility `FilledButton.icon` design.
4. **Enhanced Prompts**: Updated all AI instructions to strictly adhere to the new structured JSON format and user goals.

## Blockers
None.

## Next Steps
1. Push to feature branch and wait for user review.
2. Merge into master if approved.

## Completed (Summary)
- Project analyzed and documented in `GEMINI.md`.
- Implemented Secure API Key Management (`.env`).
- Phase 2-6: core logic, SQLite persistence, meal logging, cuisine customization, time-based validation, and professional architecture (JSON/Streaming).
- Fixed all IconData type mismatches.

## Architecture Mapping
- UI: `lib/screens/`
- State: `lib/providers/app_state.dart`
- AI Service: `lib/services/gemini_service.dart`
- Database: `lib/services/database_helper.dart`
- Models: `lib/models/user_profile.dart`, `lib/models/meal_plan.dart`
