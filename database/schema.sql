CREATE DATABASE IF NOT EXISTS sports_tournament_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE sports_tournament_db;

CREATE TABLE admins (
  admin_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE sports (
  sport_id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80) NOT NULL UNIQUE,
  allows_draw TINYINT(1) NOT NULL DEFAULT 0,
  score_label VARCHAR(30) NOT NULL DEFAULT 'Score'
) ENGINE=InnoDB;

CREATE TABLE tournaments (
  tournament_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  sport_id SMALLINT UNSIGNED NOT NULL,
  name VARCHAR(120) NOT NULL,
  format ENUM('League','Knockout') NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  venue VARCHAR(150) NOT NULL,
  team_limit TINYINT UNSIGNED NOT NULL,
  status ENUM('Upcoming','Registration','Ongoing','Completed','Cancelled') NOT NULL DEFAULT 'Upcoming',
  points_win TINYINT UNSIGNED NOT NULL DEFAULT 3,
  points_draw TINYINT UNSIGNED NOT NULL DEFAULT 1,
  points_loss TINYINT UNSIGNED NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_tournament_sport FOREIGN KEY (sport_id) REFERENCES sports(sport_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_tournament_dates CHECK (end_date >= start_date),
  CONSTRAINT chk_team_limit CHECK (team_limit BETWEEN 2 AND 64),
  CONSTRAINT uq_tournament_name UNIQUE (name)
) ENGINE=InnoDB;

CREATE TABLE teams (
  team_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  coach_name VARCHAR(100) NOT NULL,
  contact_email VARCHAR(150) NOT NULL,
  contact_phone VARCHAR(25),
  home_city VARCHAR(80) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE players (
  player_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  team_id INT UNSIGNED NOT NULL,
  full_name VARCHAR(120) NOT NULL,
  date_of_birth DATE NOT NULL,
  playing_position VARCHAR(60),
  jersey_number TINYINT UNSIGNED NOT NULL,
  CONSTRAINT fk_player_team FOREIGN KEY (team_id) REFERENCES teams(team_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT uq_team_jersey UNIQUE (team_id, jersey_number),
  CONSTRAINT chk_jersey CHECK (jersey_number BETWEEN 1 AND 99),
  INDEX idx_players_name (full_name)
) ENGINE=InnoDB;

CREATE TABLE tournament_registrations (
  registration_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tournament_id INT UNSIGNED NOT NULL,
  team_id INT UNSIGNED NOT NULL,
  registered_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_registration_tournament FOREIGN KEY (tournament_id) REFERENCES tournaments(tournament_id) ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_registration_team FOREIGN KEY (team_id) REFERENCES teams(team_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT uq_tournament_team UNIQUE (tournament_id, team_id),
  CONSTRAINT uq_registration_pair UNIQUE (registration_id, tournament_id),
  INDEX idx_registration_team (team_id)
) ENGINE=InnoDB;

CREATE TABLE matches (
  match_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tournament_id INT UNSIGNED NOT NULL,
  match_number SMALLINT UNSIGNED NOT NULL,
  round_name VARCHAR(50) NOT NULL,
  home_registration_id INT UNSIGNED NOT NULL,
  away_registration_id INT UNSIGNED NOT NULL,
  match_date DATE NOT NULL,
  match_time TIME NOT NULL,
  venue VARCHAR(150) NOT NULL,
  status ENUM('Scheduled','Completed','Postponed') NOT NULL DEFAULT 'Scheduled',
  next_match_id INT UNSIGNED NULL,
  next_slot ENUM('Home','Away') NULL,
  CONSTRAINT fk_match_tournament FOREIGN KEY (tournament_id) REFERENCES tournaments(tournament_id) ON UPDATE CASCADE ON DELETE CASCADE,
  -- RESTRICT is intentional: MySQL rejects ON UPDATE CASCADE for FK columns used by CHECK constraints.
  CONSTRAINT fk_match_home_registration FOREIGN KEY (home_registration_id, tournament_id) REFERENCES tournament_registrations(registration_id, tournament_id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT fk_match_away_registration FOREIGN KEY (away_registration_id, tournament_id) REFERENCES tournament_registrations(registration_id, tournament_id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  -- SET NULL would clear next_match_id but leave next_slot populated, violating chk_next_slot.
  CONSTRAINT fk_match_next FOREIGN KEY (next_match_id) REFERENCES matches(match_id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT uq_tournament_match_number UNIQUE (tournament_id, match_number),
  CONSTRAINT chk_different_sides CHECK (home_registration_id <> away_registration_id),
  CONSTRAINT chk_next_slot CHECK ((next_match_id IS NULL AND next_slot IS NULL) OR (next_match_id IS NOT NULL AND next_slot IS NOT NULL)),
  INDEX idx_match_schedule (match_date, match_time, status),
  INDEX idx_match_tournament_date (tournament_id, match_date)
) ENGINE=InnoDB;

CREATE TABLE match_results (
  match_id INT UNSIGNED PRIMARY KEY,
  home_score SMALLINT UNSIGNED NOT NULL,
  away_score SMALLINT UNSIGNED NOT NULL,
  winner_registration_id INT UNSIGNED NULL,
  is_draw TINYINT(1) NOT NULL DEFAULT 0,
  result_note VARCHAR(255),
  recorded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_result_match FOREIGN KEY (match_id) REFERENCES matches(match_id) ON UPDATE CASCADE ON DELETE CASCADE,
  -- winner_registration_id is read by chk_result_outcome, so its referenced key is immutable here.
  CONSTRAINT fk_result_winner FOREIGN KEY (winner_registration_id) REFERENCES tournament_registrations(registration_id) ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT chk_result_outcome CHECK ((is_draw = 1 AND home_score = away_score AND winner_registration_id IS NULL) OR (is_draw = 0 AND home_score <> away_score AND winner_registration_id IS NOT NULL)),
  INDEX idx_result_winner (winner_registration_id)
) ENGINE=InnoDB;

