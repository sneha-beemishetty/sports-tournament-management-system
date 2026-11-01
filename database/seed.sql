USE sports_tournament_db;
INSERT INTO sports (sport_id,name,allows_draw,score_label) VALUES
(1,'Football',1,'Goals'),(2,'Basketball',0,'Points'),(3,'Volleyball',0,'Sets');
INSERT INTO teams (team_id,name,coach_name,contact_email,contact_phone,home_city) VALUES
(1,'Falcons','Aarav Mehta','falcons@example.test','9000000001','Pune'),(2,'Tigers','Diya Rao','tigers@example.test','9000000002','Mumbai'),(3,'Warriors','Kabir Shah','warriors@example.test','9000000003','Nashik'),(4,'Eagles','Mira Das','eagles@example.test','9000000004','Pune'),(5,'Sharks','Neel Iyer','sharks@example.test','9000000005','Nagpur');
INSERT INTO players (team_id,full_name,date_of_birth,playing_position,jersey_number) VALUES
(1,'Aman Joshi','2005-04-12','Forward',9),(1,'Ishita Kulkarni','2004-08-09','Midfielder',8),(2,'Rohan Patil','2005-01-22','Goalkeeper',1),(2,'Sara Khan','2004-05-18','Defender',4),(3,'Dev Nair','2005-09-02','Forward',10),(4,'Anaya Singh','2004-03-11','Midfielder',7),(5,'Vivaan Bose','2005-06-20','Defender',5);
INSERT INTO tournaments (tournament_id,sport_id,name,format,start_date,end_date,venue,team_limit,status,points_win,points_draw,points_loss) VALUES
(1,1,'Inter-College Football League','League','2026-10-01','2026-11-15','University Sports Ground',8,'Ongoing',3,1,0),
(2,2,'Campus Basketball Cup','Knockout','2026-11-01','2026-11-20','Indoor Arena',4,'Registration',2,0,0),
(3,3,'Volleyball Friendly','League','2026-12-01','2026-12-10','North Court',6,'Upcoming',2,0,0);
INSERT INTO tournament_registrations (registration_id,tournament_id,team_id) VALUES (1,1,1),(2,1,2),(3,1,3),(4,1,4),(5,2,1),(6,2,2),(7,2,5);
INSERT INTO matches (match_id,tournament_id,match_number,round_name,home_registration_id,away_registration_id,match_date,match_time,venue,status) VALUES
(1,1,1,'Round 1',1,2,'2026-10-20','15:00:00','University Sports Ground','Completed'),
(2,1,2,'Round 1',3,4,'2026-10-21','15:00:00','University Sports Ground','Completed'),
(3,1,3,'Round 2',1,3,'2026-10-30','16:00:00','University Sports Ground','Scheduled'),
(4,2,1,'Semi-final',5,6,'2026-11-10','14:00:00','Indoor Arena','Scheduled');
INSERT INTO match_results (match_id,home_score,away_score,winner_registration_id,is_draw,result_note) VALUES (1,2,1,1,0,'Falcons scored in the final minute'),(2,0,0,NULL,1,'Goalless draw');
