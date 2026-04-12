# Project Memory

## Project Goal
Develop the Smart Diet Assistant, a Flutter-based mobile health platform for elderly Malaysians that uses Google Gemini AI for culturally tailored meal planning.

## Active Phase
Phase 12: Persistent Accounts & Family Cloud Logic
1. **User Database**: Implemented a `users` table in SQLite to store persistent account details (Email, Password, Connection Code, Profile).
2. **Credential Memory**: The login screen now automatically remembers and pre-populates the last used Email and Password for a seamless re-entry.
3. **Disconnected Family Linking**: Family members can now link to a user's data using the 7-char code at any time, even if the primary user is logged out.
4. **Persistent Multi-Account support**: The app is now architected to handle multiple registered users on the same device.

## Blockers
None.

## Next Steps
1. Push to feature branch and wait for user review.
2. Merge into master if approved.

## Completed (Summary)
- Project analyzed and documented in `GEMINI.md`.
- Phase 2-11: Core logic, SQLite, specialized cuisine, AI chat, goals, AI Vision, and Medical PDF reporting.
- All UI button designs and color schemes finalized.

## Architecture Mapping
- UI: `lib/screens/`
- State: `lib/providers/app_state.dart`
- AI Service: `lib/services/gemini_service.dart`, `lib/services/pdf_service.dart`
- Database: `lib/services/database_helper.dart` (Managing Users, History, and Food)
- Models: `lib/models/user_profile.dart`, `lib/models/meal_plan.dart`
