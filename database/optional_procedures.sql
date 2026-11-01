USE sports_tournament_db;
DELIMITER $$
CREATE PROCEDURE RegisterTeam(IN p_tournament_id INT UNSIGNED, IN p_team_id INT UNSIGNED)
BEGIN
  DECLARE current_count INT;
  DECLARE max_count INT;
  START TRANSACTION;
  SELECT team_limit INTO max_count FROM tournaments WHERE tournament_id=p_tournament_id AND status IN ('Upcoming','Registration') FOR UPDATE;
  IF max_count IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Tournament is not accepting registrations'; END IF;
  SELECT COUNT(*) INTO current_count FROM tournament_registrations WHERE tournament_id=p_tournament_id;
  IF current_count >= max_count THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Tournament team limit reached'; END IF;
  INSERT INTO tournament_registrations(tournament_id,team_id) VALUES(p_tournament_id,p_team_id);
  COMMIT;
END$$
DELIMITER ;
