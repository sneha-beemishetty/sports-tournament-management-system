# Normalization notes

**Dependencies and keys.** In Players, player_id → team_id, full_name, date_of_birth, playing_position, jersey_number; (team_id, jersey_number) is also a candidate key. In Tournament_Registrations, registration_id → tournament_id, team_id and (tournament_id, team_id) → registration_id, registered_at. In Matches, match_id → all match attributes and (tournament_id, match_number) is a candidate key. In Match_Results, match_id → scores, winner, draw flag and note. Tournament IDs determine tournament attributes; sport_id determines sport configuration.

**1NF:** Store one scalar score per side and one team per registration; do not store comma-separated rosters or fixtures in a tournament row.

**2NF:** A naive results sheet might key a row by (tournament_id, match_number, side) and repeat tournament name, venue, and sport for each side. Move tournament-level facts to Tournaments and each match's facts to Matches; no non-key attribute depends on only part of a composite key in the resulting relations. The implemented relations use single-column surrogate keys except explicit candidate keys.

**3NF:** A flat match table containing sport name and sport rules would have match_id → tournament_id → sport_id → sport_name/allow_draw, a transitive dependency. Those facts live in Sports/Tournaments. Team contact data and player data likewise live in Teams and Players instead of repeating per fixture. Each non-key attribute depends on a key, the whole key, and nothing but the key. Registration joins team and tournament without copying either entity's descriptive facts.

This decomposition prevents update anomalies (change a sport once), insertion anomalies (add a team before a fixture), and deletion anomalies (removing one match does not erase team/player details). Draw/winner consistency and some cross-row policies are validated in application transactions because ordinary CHECK constraints cannot inspect another table.
