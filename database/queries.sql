USE sports_tournament_db;

-- DDL demonstrations (run ALTER once; DROP is deliberately isolated as a demo).
CREATE TABLE IF NOT EXISTS query_demo (id INT PRIMARY KEY, note VARCHAR(40) NOT NULL);
ALTER TABLE query_demo ADD COLUMN created_on DATE NULL;
INSERT INTO query_demo (id,note) VALUES (1,'DDL demo');
UPDATE query_demo SET note='updated demo' WHERE id=1;
DELETE FROM query_demo WHERE id=1;
DROP TABLE query_demo;

-- 1. Upcoming fixtures
SELECT * FROM v_upcoming_matches ORDER BY match_date,match_time;
-- 2. Players on Falcons
SELECT p.full_name,p.playing_position,p.jersey_number FROM players p JOIN teams t USING(team_id) WHERE t.name='Falcons' ORDER BY p.jersey_number;
-- 3. Completed results and winner
SELECT m.match_number,ht.name home_team,mr.home_score,at.name away_team,mr.away_score,wt.name winner,mr.is_draw
FROM matches m JOIN match_results mr USING(match_id) JOIN tournament_registrations hr ON hr.registration_id=m.home_registration_id JOIN teams ht ON ht.team_id=hr.team_id
JOIN tournament_registrations ar ON ar.registration_id=m.away_registration_id JOIN teams at ON at.team_id=ar.team_id LEFT JOIN tournament_registrations wr ON wr.registration_id=mr.winner_registration_id LEFT JOIN teams wt ON wt.team_id=wr.team_id;
-- 4. Team count by tournament
SELECT t.name,COUNT(tr.registration_id) team_count FROM tournaments t LEFT JOIN tournament_registrations tr USING(tournament_id) GROUP BY t.tournament_id,t.name ORDER BY team_count DESC;
-- 5. Distinct tournament formats
SELECT DISTINCT format FROM tournaments;
-- 6. Aggregate score range
SELECT COUNT(*) results,SUM(home_score+away_score) total_score,AVG(home_score+away_score) average_goals,MIN(home_score+away_score) minimum,MAX(home_score+away_score) maximum FROM match_results;
-- 7. Standings (points then goal difference then goals scored)
SELECT t.name,s.team_name,s.played,s.wins,s.draws,s.losses,s.points,(s.scored-s.conceded) goal_difference,s.scored FROM v_league_standings s JOIN tournaments t USING(tournament_id) WHERE t.format='League' ORDER BY t.tournament_id,s.points DESC,goal_difference DESC,s.scored DESC,s.team_name;
-- 8. Teams without any fixtures
SELECT tm.name FROM teams tm WHERE NOT EXISTS (SELECT 1 FROM tournament_registrations tr JOIN matches m ON m.tournament_id=tr.tournament_id AND (m.home_registration_id=tr.registration_id OR m.away_registration_id=tr.registration_id) WHERE tr.team_id=tm.team_id);
-- 9. Tournaments without teams
SELECT t.name FROM tournaments t WHERE NOT EXISTS (SELECT 1 FROM tournament_registrations tr WHERE tr.tournament_id=t.tournament_id);
-- 10. Players in multiple tournaments (team roster membership)
SELECT p.full_name,COUNT(DISTINCT tr.tournament_id) tournament_count FROM players p JOIN tournament_registrations tr USING(team_id) GROUP BY p.player_id,p.full_name HAVING COUNT(DISTINCT tr.tournament_id)>1;
-- 11. Team result record: wins, draws, losses, played, points (correlated subqueries)
SELECT tr.tournament_id,tm.name,
 (SELECT COUNT(*) FROM matches m JOIN match_results r USING(match_id) WHERE m.tournament_id=tr.tournament_id AND r.winner_registration_id=tr.registration_id) wins,
 (SELECT COUNT(*) FROM matches m JOIN match_results r USING(match_id) WHERE m.tournament_id=tr.tournament_id AND r.is_draw=1 AND tr.registration_id IN (m.home_registration_id,m.away_registration_id)) draws,
 (SELECT COUNT(*) FROM matches m JOIN match_results r USING(match_id) WHERE m.tournament_id=tr.tournament_id AND tr.registration_id IN (m.home_registration_id,m.away_registration_id)) played
FROM tournament_registrations tr JOIN teams tm USING(team_id);
-- 12. Most teams in a tournament (subquery)
SELECT t.name,COUNT(*) team_count FROM tournaments t JOIN tournament_registrations tr USING(tournament_id) GROUP BY t.tournament_id,t.name HAVING COUNT(*)=(SELECT MAX(c) FROM (SELECT COUNT(*) c FROM tournament_registrations GROUP BY tournament_id) counts);
-- 13. Tournament search/date/status filters
SELECT name,format,status FROM tournaments WHERE status IN ('Registration','Ongoing') AND start_date>='2026-10-01' ORDER BY start_date;
-- 14. LEFT JOIN identifies teams that have not played, including registered and unregistered
SELECT tm.name,COUNT(DISTINCT m.match_id) matches_scheduled FROM teams tm LEFT JOIN tournament_registrations tr USING(team_id) LEFT JOIN matches m ON m.tournament_id=tr.tournament_id AND tr.registration_id IN(m.home_registration_id,m.away_registration_id) GROUP BY tm.team_id,tm.name;
-- 15. Self join: pairs of teams registered in the same tournament
SELECT t.name,ta.name team_a,tb.name team_b FROM tournament_registrations a JOIN tournament_registrations b ON b.tournament_id=a.tournament_id AND b.team_id>a.team_id JOIN tournaments t ON t.tournament_id=a.tournament_id JOIN teams ta ON ta.team_id=a.team_id JOIN teams tb ON tb.team_id=b.team_id;
-- 16. WHERE / ORDER BY completed match scores
SELECT match_id,home_score,away_score FROM match_results WHERE home_score>=1 OR away_score>=1 ORDER BY home_score+away_score DESC;
-- Transaction example: rollback a temporary status change
START TRANSACTION; UPDATE tournaments SET status='Cancelled' WHERE tournament_id=3; ROLLBACK;
-- Constraint examples (uncomment individually to observe errors): duplicate team name, invalid date range, unknown FK.
-- INSERT INTO teams(name,coach_name,contact_email) VALUES('Falcons','X','x@example.test');
-- INSERT INTO tournaments(sport_id,name,format,start_date,end_date,venue,team_limit) VALUES(1,'Bad date','League','2026-12-10','2026-12-01','X',4);
