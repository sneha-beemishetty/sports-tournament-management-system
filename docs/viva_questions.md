# DBMS viva questions and simple answers

1. **Why MySQL?** It is a widely used relational DBMS with constraints, transactions, indexes, views and easy local installation.
2. **What is a primary key?** A column or column set that uniquely identifies each row and cannot be null.
3. **What is a foreign key?** A constraint requiring a referenced value to exist in a parent table, preserving referential integrity.
4. **What does the ER diagram show?** Entities, their attributes, and how many rows may relate across entities.
5. **What does 1:M mean here?** One team can have many player rows, while each player belongs to one team.
6. **Why is tournament_registrations needed?** It resolves the many-to-many relationship between teams and tournaments.
7. **What is a candidate key?** Any minimal attribute set capable of uniquely identifying a row; a table may have several.
8. **What is 1NF?** Each field contains one atomic value; repeating lists are modeled as separate rows.
9. **What is 2NF?** The relation is in 1NF and every non-key attribute depends on the whole candidate key.
10. **What is 3NF?** The relation is in 2NF and non-key attributes do not depend transitively on a key through another non-key attribute.
11. **Which anomalies does normalization reduce?** Repeated facts can cause inconsistent updates, block independent inserts, and disappear accidentally during deletes.
12. **What is an INNER JOIN?** It returns rows with matching keys in both joined relations.
13. **What is a LEFT JOIN?** It preserves all left-side rows and fills missing right-side values with NULL.
14. **What is a subquery?** A query nested in another query, often used for filtering or derived values.
15. **What does EXISTS do?** It tests whether a subquery returns at least one row.
16. **What is a view?** A named stored SELECT that presents derived data like a virtual table.
17. **Why use UNIQUE?** It prevents duplicate values or duplicate combinations such as team and jersey number.
18. **What is a CHECK constraint?** A row-level boolean rule enforced when values are inserted or updated.
19. **What is a transaction?** A group of operations treated as one unit; commit saves them and rollback cancels them.
20. **What are ACID properties?** Atomicity, consistency, isolation and durability describe reliable transaction behavior.
21. **Why use indexes?** They speed lookup and joins, at the cost of storage and extra work on writes.
22. **What is a trigger?** Database code automatically run on a table event; this project instead uses an optional procedure for bounded registration.
23. **What is a stored procedure?** A named SQL routine stored in the database and called with parameters.
24. **How are league points calculated?** For each completed match, the winner gets configured win points, a draw gives configured draw points to each side, and a loser gets configured loss points.
25. **How are standings tie-broken?** Points, score difference, score for, then team name; this rule is documented for the demo.
26. **How does the schema ensure a match team belongs to its tournament?** Composite foreign keys reference `(registration_id,tournament_id)` in tournament registrations.
27. **Why are results separate from matches?** A fixture may not yet have a result, and a shared primary key enforces at most one result per match.
28. **How are passwords stored?** Only bcrypt hashes are stored; plaintext is compared through bcrypt during login.
29. **How does the app reduce SQL injection risk?** User values are passed through prepared statement placeholders rather than concatenated into SQL.
30. **Where are transactions used?** Team registration locks the tournament row while checking capacity; result entry updates the score and match status atomically.
