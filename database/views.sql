USE sports_tournament_db;
CREATE OR REPLACE VIEW v_upcoming_matches AS
SELECT m.match_id,t.name AS tournament_name,m.round_name,m.match_number,m.match_date,m.match_time,m.venue,
       ht.name AS home_team,at.name AS away_team,m.status
FROM matches m JOIN tournaments t ON t.tournament_id=m.tournament_id
JOIN tournament_registrations hr ON hr.registration_id=m.home_registration_id
JOIN teams ht ON ht.team_id=hr.team_id
JOIN tournament_registrations ar ON ar.registration_id=m.away_registration_id
JOIN teams at ON at.team_id=ar.team_id
WHERE m.status IN ('Scheduled','Postponed');

CREATE OR REPLACE VIEW v_league_standings AS
SELECT tr.tournament_id,tr.registration_id,tm.name AS team_name,
 SUM(CASE WHEN mr.match_id IS NOT NULL THEN 1 ELSE 0 END) AS played,
 SUM(CASE WHEN mr.is_draw=0 AND mr.winner_registration_id=tr.registration_id THEN 1 ELSE 0 END) AS wins,
 SUM(CASE WHEN mr.is_draw=1 THEN 1 ELSE 0 END) AS draws,
 SUM(CASE WHEN mr.is_draw=0 AND mr.winner_registration_id IS NOT NULL AND mr.winner_registration_id<>tr.registration_id THEN 1 ELSE 0 END) AS losses,
 SUM(CASE WHEN mr.winner_registration_id=tr.registration_id THEN t.points_win WHEN mr.is_draw=1 THEN t.points_draw WHEN mr.match_id IS NOT NULL THEN t.points_loss ELSE 0 END) AS points,
 SUM(CASE WHEN m.home_registration_id=tr.registration_id THEN mr.home_score WHEN m.away_registration_id=tr.registration_id THEN mr.away_score ELSE 0 END) AS scored,
 SUM(CASE WHEN m.home_registration_id=tr.registration_id THEN mr.away_score WHEN m.away_registration_id=tr.registration_id THEN mr.home_score ELSE 0 END) AS conceded
FROM tournament_registrations tr JOIN tournaments t ON t.tournament_id=tr.tournament_id JOIN teams tm ON tm.team_id=tr.team_id
LEFT JOIN matches m ON m.tournament_id=tr.tournament_id AND (m.home_registration_id=tr.registration_id OR m.away_registration_id=tr.registration_id) AND m.status='Completed'
LEFT JOIN match_results mr ON mr.match_id=m.match_id
GROUP BY tr.tournament_id,tr.registration_id,tm.name;
