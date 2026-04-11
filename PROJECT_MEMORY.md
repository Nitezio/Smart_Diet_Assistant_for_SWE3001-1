# Project Memory

## Project Goal
Develop the Smart Diet Assistant, a Flutter-based mobile health platform for elderly Malaysians that uses Google Gemini AI for culturally tailored meal planning.

## Active Phase
Phase 10: Medical Reporting & Long-term Analytics
1. **Trend Visualization**: Integrated `fl_chart` to display a 7-day calorie trend bar chart in the Tracker tab for caregivers.
2. **Medical PDF Export**: Implemented `PdfService` to generate professional, doctor-ready health reports including profile data and full meal history.
3. **Database Aggregation**: Added SQLite aggregation logic to `DatabaseHelper` for efficient statistics calculation.
4. **Caregiver Insights**: Enhanced the Tracker tab to provide clear, actionable trends beyond simple daily totals.

## Blockers
None.

## Next Steps
1. Push to feature branch and wait for user review.
2. Merge into master if approved.

## Completed (Summary)
- Project analyzed and documented in `GEMINI.md`.
- Phase 2-9: core logic, SQLite, specialized cuisine, AI chat, health goals, and AI Vision (plate scanner).
- Finalized professional architecture with JSON AI output and streaming.

## Architecture Mapping
- UI: `lib/screens/`
- State: `lib/providers/app_state.dart`
- AI Service: `lib/services/gemini_service.dart`, `lib/services/pdf_service.dart`
- Database: `lib/services/database_helper.dart`
- Models: `lib/models/user_profile.dart`, `lib/models/meal_plan.dart`
