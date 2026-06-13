-- Task 1: Create the friends table
CREATE TABLE friends (
    id INTEGER,
    name TEXT,
    birthday DATE
);

-- Task 2: Add Ororo Munroe
INSERT INTO friends (id, name, birthday)
VALUES (1, 'Ororo Munroe', '1940-05-30');

-- Task 3: Verify Ororo was added
SELECT * FROM friends;

-- Task 4: Add two more friends
INSERT INTO friends (id, name, birthday)
VALUES (2, 'Peter Parker', '2001-08-10');

INSERT INTO friends (id, name, birthday)
VALUES (3, 'Bruce Wayne', '1972-02-19');

-- Optional: Verify all friends were added
SELECT * FROM friends;

-- Task 5: Update Ororo's name to Storm
UPDATE friends
SET name = 'Storm'
WHERE id = 1;

-- Task 6: Add email column
ALTER TABLE friends
ADD COLUMN email TEXT;

-- Task 7: Update email addresses for everyone
UPDATE friends
SET email = 'storm@codecademy.com'
WHERE id = 1;

UPDATE friends
SET email = 'peter.parker@dailybugle.com'
WHERE id = 2;

UPDATE friends
SET email = 'bruce.wayne@wayneenterprises.com'
WHERE id = 3;

-- Task 8: Remove Storm (fictional character) from friends
DELETE FROM friends
WHERE id = 1;

-- Task 9: Final view of the table
SELECT * FROM friends;