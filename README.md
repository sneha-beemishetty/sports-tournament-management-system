# Sports Tournament and Match Management System

A beginner-friendly DBMS project for managing college sports tournaments with a MySQL 8 database and a Node.js/Express web application.

## Abstract and problem statement

College tournaments often track team entries, schedules, scores and tables in separate spreadsheets. This causes duplicates and makes standings hard to verify. This project centralizes those records in a relational database and provides public browsing plus protected organizer forms.

## Objectives and scope

- Demonstrate relational design, keys, constraints, joins, views, transactions and normalized data.
- Let organizers maintain tournaments, team and player rosters, registrations, fixtures and results.
- Let visitors browse tournaments, matches, results, standings and knockout match cards.
- Standings are calculated from recorded completed results, not stored as duplicate totals.

The demo is intended for a trusted local class project. It uses Express's in-memory session store, so sessions reset when the server restarts; use a production session store, HTTPS and rate limiting before public deployment. Team/player editing and removal, automatic round-robin generation, and a full bracket builder are not included. Knockout advancement is represented by optional `next_match_id`/`next_slot` fixture links and can be configured in SQL, while winners are displayed; organizers must create the next fixture. Scheduling rejects same-team matches with the same date and kickoff time; sport-specific match durations and venue conflicts need domain-specific policy.

## Stack and requirements

Node.js 18+ (20 LTS recommended), npm, MySQL 8.x, a modern browser and Bootstrap 5 via CDN. No ORM is used; all values are sent through mysql2 placeholders.

## Database design first

The core entities are Sports, Tournaments, Teams, Players, Tournament_Registrations, Matches, Match_Results and Admins. A sport classifies many tournaments (1:M); a team has many players (1:M); teams and tournaments are M:N through registrations. A tournament has many matches. Each match references exactly two registrations in its own tournament. A match has zero or one result (1:0..1). A result's optional winner points to one registration. Knockout matches may link to a later match and slot through a self-reference.

Business rules: names used as natural identifiers are unique; a team can register once per tournament; a jersey number can be used once per team; a match's sides must differ and both be registered; only completed matches have results in normal application use; draws have equal scores and no winner, decisive results have unequal scores and a winner. Sport draw policy is read from `sports`. Tournament points are configurable. Composite foreign keys on matches enforce the registration/tournament match.

### MySQL 8.0.46 check-constraint compatibility

MySQL rejects a column in a `CHECK` constraint when the same foreign-key column can be modified by a cascading referential action. The match-side IDs, knockout destination ID and result winner ID are checked by row constraints, so their foreign keys use `ON UPDATE RESTRICT` (and `RESTRICT` deletion where changing only one linked value could violate a check). This keeps both the checks and foreign keys in place. The app deletes a tournament in one transaction by clearing both knockout-link fields, deleting its matches/results, then its registrations, then the tournament.

### Read the ER diagram

Open [`docs/er_diagram.mmd`](docs/er_diagram.mmd) in a Mermaid-compatible editor. The crow's-foot markers show one-to-many relations. The bridge `TOURNAMENT_REGISTRATIONS` turns the team/tournament many-to-many relation into two one-to-many relationships. `MATCH_RESULTS` shares its primary key with its parent match, which enforces at most one result. The two registration links in MATCHES mean home and away. The self-link is optional and used to express a knockout destination. ADMIN has no domain-record relationship because it only authenticates organizers.

The written schema, data dictionary, dependencies and normalization example are in [`docs/relational_schema.md`](docs/relational_schema.md), [`docs/data_dictionary.md`](docs/data_dictionary.md) and [`docs/normalization.md`](docs/normalization.md).

### Normalization summary

For example, `match_id` determines the match's tournament, date, sides and venue. Tournament ID determines tournament name and points; sport ID determines sport name and draw policy. Storing sport name in every match would create `match_id → tournament_id → sport_id → sport_name`, a transitive dependency. Sports and tournaments therefore hold their own facts. A registration's candidate keys are `registration_id` and `(tournament_id, team_id)`. Players have candidate keys `player_id` and `(team_id, jersey_number)`. This makes updates occur once and avoids losing a team's details when a fixture is deleted.

## Installation on Windows

Open PowerShell in this folder.

```powershell
npm install
Copy-Item .env.example .env
```

Edit `.env` and set `DB_USER`, `DB_PASSWORD`, and a long random `SESSION_SECRET`. In MySQL Workbench, connect to your local MySQL Server 8.0.46 connection, then open each SQL file with **File → Open SQL Script**. Run each complete script with the lightning-bolt **Execute** button (or Ctrl+Shift+Enter) in this order:

1. `database/reset.sql` — optional fresh reset; this drops all existing data in `sports_tournament_db`.
2. `database/schema.sql` — creates all tables and constraints.
3. `database/seed.sql` — inserts the demonstration data.
4. `database/views.sql` — creates the two demonstration views.

After each run, confirm the Action Output panel reports success before continuing. Skip `reset.sql` if you need to keep existing data. The scripts can also be run through the MySQL command-line client if installed.

Optional procedure (run once):

```powershell
mysql -u root -p < database/optional_procedures.sql
```

The schema includes `home_city` directly in `teams` so it can be imported in one pass. `database/queries.sql` contains an illustrative CREATE/ALTER/DROP sequence for a temporary `query_demo` table; do not run it if that table contains data. `database/optional_procedures.sql` can be run once after the views if you want the optional registration procedure.

Create a local admin account. Choose your own password; it is hashed with bcrypt and never put in source control:

```powershell
npm run admin:create -- admin YourLongLocalPassword123
npm run dev
```

Open <http://localhost:3000>. Public pages work without login. Use `/login` for organizer actions. `npm start` runs without watch mode. `.env` is ignored by Git.

Seed data includes three sports, three tournaments, five teams, seven players, registrations, scheduled fixtures, two results and demo standings. Dates are chosen relative to October 2026. `database/queries.sql` has 16 meaningful SELECT demonstrations and isolated DDL/DML/transaction examples. Run it in a disposable/test database if exercising its DDL demonstration: it creates and drops a table named `query_demo`. `database/views.sql` defines upcoming fixtures and standings.

## Feature guide

- Home: tournament list, upcoming matches and recent scores.
- Admin dashboard: SQL-derived totals and fixture/result summaries.
- Tournaments: create, list, search, delete; format, dates, points and capacity.
- Teams: create/search, register to an accepting tournament, view registrations.
- Players: create/search, roster and unique team jersey numbers.
- Matches: filter by tournament/status, schedule using registration IDs, enter scores or change status.
- Standings: configurable points, played/win/draw/loss and score difference; ordered by points, difference, score-for, team name.
- Knockout: match cards show rounds and winners. Set destination fields for bracket linkage when defining fixtures; automatic advancement is not yet part of the UI.

## Important SQL query examples

The full runnable collection is in `database/queries.sql`. Examples include:

```sql
SELECT * FROM v_upcoming_matches ORDER BY match_date, match_time;
SELECT t.name, COUNT(tr.registration_id) AS team_count
FROM tournaments t LEFT JOIN tournament_registrations tr USING (tournament_id)
GROUP BY t.tournament_id, t.name;
SELECT * FROM v_league_standings
ORDER BY points DESC, (scored-conceded) DESC, scored DESC;
```

With seed data, upcoming fixtures include Falcons vs Warriors (30 Oct 2026) and Falcons vs Tigers (10 Nov 2026). Registration counts are Football League 4, Basketball Cup 3 and Volleyball Friendly 0. In Football League, Falcons have 3 points from one win; Warriors and Eagles each have 1 from a draw; Tigers have 0. The 16 query comments each state the question answered. MySQL `CHECK` constraints enforce row-local rules; cross-table registration and sport draw-policy rules are checked in transactional application code.

## Testing checklist

No automated test suite is included. Run the app against a disposable local database and manually verify:

1. Database: import scripts, confirm `SELECT COUNT(*) FROM teams` returns 5 and views select successfully.
2. Login/logout: unauthenticated `/admin` redirects to login; valid admin signs in; logout clears session.
3. Tournament: create a valid league, reject end date before start, duplicate names rejected; delete a tournament and verify its registrations/fixtures cascade.
4. Registration: register a team, repeat it and see duplicate feedback; fill the capacity and confirm another registration is rejected.
5. Player: add a player; duplicate jersey on same team fails; same jersey on another team is allowed.
6. Match: valid registrations schedule; same registration and unregistered registration fail; same-team exact kickoff overlap fails.
7. Result: record a valid score; edit it; reject a draw in Basketball; set scheduled and confirm result is removed; public standings reflect new result.
8. Knockout: create fixtures with a destination link and ensure match cards include completed winners. Automatic slot population is not implemented.
9. Constraints: try duplicate names, invalid dates, self-play and missing foreign keys using the commented SQL examples or a disposable DB.
10. Security: protected POST redirects without session; forms without valid CSRF token return 403; SQL-like search strings are treated as values.
11. Invalid forms and missing IDs produce a readable error page without a stack trace.

The local project environment may not have MySQL available; only claim runtime checks after executing them with a configured database.

## Future enhancements

Add automatic league fixture generation, knockout slot advancement, team/player update and delete forms, scheduling duration/venue conflict rules, persistent session storage, rate limits, audit history and automated tests using a dedicated test database.

See [`docs/viva_questions.md`](docs/viva_questions.md) for oral-exam preparation.
