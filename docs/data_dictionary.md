# Data dictionary

| Table | Purpose and notable rules |
|---|---|
| admins | Local administrator login; stores bcrypt hash only; username unique. |
| sports | Sport configuration including whether a draw is permitted and score label. |
| tournaments | Tournament schedule, format, status and configurable league points. Dates ordered; team limit 2–64. |
| teams | Club/squad contact and coach details; unique name. |
| players | Roster members; team cascade delete; jersey unique within team. |
| tournament_registrations | M:N bridge from teams to tournaments; duplicate pair prohibited. |
| matches | Fixture with registered sides, unique tournament match number and optional knockout destination slot. Self-play prohibited. |
| match_results | Optional 1:1 completed result; draw has equal scores/no winner; decisive result has a winner. |

Delete policy: deleting a tournament cascades its registrations and fixtures/results; teams cannot be deleted while registered; deleting a team cascades its players. Sport deletion is restricted while tournaments use it. Home/away registrations, knockout destinations and result winners use `RESTRICT` for key updates/deletes: those columns participate in row-level checks and referenced IDs are stable identifiers.
