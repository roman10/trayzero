-- Synthetic Things 3.17+ export. Field names/types checked against the
-- thingsapi/things.py public test database; no third-party user data copied.
CREATE TABLE TMTask (
 uuid TEXT PRIMARY KEY, type INTEGER, status INTEGER DEFAULT 0,
 trashed INTEGER DEFAULT 0, title TEXT, notes TEXT,
 start INTEGER DEFAULT 1, startDate INTEGER, deadline INTEGER,
 "index" INTEGER DEFAULT 0, area TEXT, project TEXT, heading TEXT,
 reminderTime INTEGER, rt1_recurrenceRule BLOB,
 rt1_repeatingTemplate TEXT, repeater BLOB
);
CREATE TABLE TMArea (uuid TEXT PRIMARY KEY, title TEXT);
CREATE TABLE TMTag (uuid TEXT PRIMARY KEY, title TEXT, parent TEXT);
CREATE TABLE TMTaskTag (tasks TEXT, tags TEXT);
CREATE TABLE TMChecklistItem (
 uuid TEXT PRIMARY KEY, title TEXT, status INTEGER DEFAULT 0,
 "index" INTEGER DEFAULT 0, task TEXT
);
INSERT INTO TMArea VALUES ('area', 'Family');
INSERT INTO TMTag VALUES ('tag-home', '@home', NULL), ('tag-weekend', 'weekend', NULL);
INSERT INTO TMTask (uuid, type, title, notes, area) VALUES
 ('project', 1, 'Kitchen', 'New cabinets', 'area');
INSERT INTO TMTask (uuid, type, title, project) VALUES
 ('heading', 2, 'Preparation', 'project');
INSERT INTO TMTask (uuid, type, title, start, "index") VALUES
 ('inbox', 0, 'Capture idea', 0, 1),
 ('someday', 0, 'Learn 日本語', 2, 5),
 ('closed', 0, 'Already done', 1, 6),
 ('cancelled', 0, 'Cancelled task', 1, 7),
 ('trashed', 0, 'Trashed task', 1, 8);
UPDATE TMTask SET status = 3 WHERE uuid = 'closed';
UPDATE TMTask SET status = 2 WHERE uuid = 'cancelled';
UPDATE TMTask SET trashed = 1 WHERE uuid = 'trashed';
INSERT INTO TMTask (uuid, type, title, notes, heading, "index", startDate, deadline)
 VALUES ('action', 0, 'Measure walls', 'Bring tape', 'heading', 2,
         (2026 << 16) | (11 << 12) | (4 << 7),
         (2026 << 16) | (11 << 12) | (10 << 7));
INSERT INTO TMTaskTag VALUES ('action', 'tag-home'), ('action', 'tag-weekend');
INSERT INTO TMChecklistItem VALUES
 ('check-2', 'Take a photo', 0, 2, 'action'),
 ('check-1', 'Find tape', 3, 1, 'action');
