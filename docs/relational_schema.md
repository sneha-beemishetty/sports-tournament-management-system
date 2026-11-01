# Relational schema

- Admins(**admin_id**, username UQ, password_hash, created_at)
- Sports(**sport_id**, name UQ, allows_draw, score_label)
- Tournaments(**tournament_id**, sport_id FK, name UQ, format, start_date, end_date, venue, team_limit, status, points_win, points_draw, points_loss)
- Teams(**team_id**, name UQ, coach_name, contact_email, contact_phone, home_city)
- Players(**player_id**, team_id FK, full_name, date_of_birth, playing_position, jersey_number; UQ(team_id, jersey_number))
- Tournament_Registrations(**registration_id**, tournament_id FK, team_id FK; UQ(tournament_id, team_id), UQ(registration_id,tournament_id))
- Matches(**match_id**, tournament_id FK, match_number, round_name, home_registration_id, away_registration_id, match_date, match_time, venue, status, next_match_id, next_slot; composite FKs (registration_id,tournament_id) ensure each side registered for that tournament)
- Match_Results(**match_id** FK, home_score, away_score, winner_registration_id FK nullable, is_draw, result_note)

The registration key is a surrogate primary key; (tournament_id, team_id) is a candidate key. A match result has the same key as its match, enforcing at most one result per match.
