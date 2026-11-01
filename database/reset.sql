-- DESTRUCTIVE: this permanently removes and recreates the project database.
-- Use only when you want a fresh setup and are willing to delete all its data.
DROP DATABASE IF EXISTS sports_tournament_db;
CREATE DATABASE sports_tournament_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
