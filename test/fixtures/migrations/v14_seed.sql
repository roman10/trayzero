BEGIN;

INSERT INTO areas (id, name) VALUES ('home', 'Home'), ('work', 'Work');

INSERT INTO contexts (id, name, icon, color, sort_order)
VALUES ('errands', 'Errands', 'shopping_cart', 4280391411, 4);
INSERT INTO contexts (id, name) VALUES ('phone', 'Phone');

INSERT INTO projects (id, title, outcome, area_id, status, due_at, created_at,
                      updated_at, last_reviewed_at)
VALUES ('p', 'Garage', 'Car fits', 'home', 'active', 1795599000, 1794907800,
        1794994200, 1794994200);
INSERT INTO projects (id, title, created_at, updated_at)
VALUES ('q', 'Paperwork', 1794907900, 1794907900);

INSERT INTO items (id, title, notes, status, project_id, context_id,
                   defer_until, energy, time_estimate_minutes, is_two_min,
                   created_at, updated_at, sort_order, project_sort_order,
                   recurrence, recurrence_interval, recurrence_count,
                   recurrence_done_count, recurrence_by_weekdays, search_text,
                   focused_at)
VALUES ('a', 'Visit the Café', 'near São Paulo', 'nextAction', 'p', 'errands',
        1795080600, 'high', 2, 1, 1794907800, 1794994200, 3, 5, 'weekly', 2,
        6, 2, '1,3', 'visit the cafe' || char(10) || 'near sao paulo', 1794994200);

INSERT INTO items (id, title, status, project_id, due_at, created_at,
                   updated_at, completed_at, previous_status, recurrence,
                   recurrence_until, recurrence_monthly_week,
                   recurrence_monthly_weekday, search_text)
VALUES ('b', 'Dentist', 'done', 'p', 1794994200, 1794907800, 1794994200,
        1794994200, 'calendar', 'monthly', 1800000000, -1, 4,
        'dentist' || char(10));

INSERT INTO items (id, title, status, waiting_on, created_at, updated_at, search_text)
VALUES ('c', 'Get a quote', 'waiting', 'Alice', 1794907800, 1794994200,
        'get a quote' || char(10));

INSERT INTO items (id, title, status, due_at, calendar_event_id, created_at,
                   updated_at, search_text)
VALUES ('d', 'Garage inspection', 'calendar', 1795080600, 'inspection',
        1794907800, 1794994200, 'garage inspection' || char(10));

INSERT INTO attachments (id, item_id, kind, path, name, size_bytes, created_at)
VALUES ('pdf', 'a', 'file', 'attachments/receipt.pdf', 'receipt.pdf', 2481, 1794994200);
INSERT INTO attachments (id, item_id, kind, path, created_at)
VALUES ('photo', 'b', 'image', 'attachments/photo.jpg', 1794994200);

INSERT INTO reviews (id, type, started_at, completed_at, notes, current_step)
VALUES ('finished', 'weekly', 1794389400, 1794389700, 'Cleaned the inbox', 'someday');
INSERT INTO reviews (id, type, started_at, current_step)
VALUES ('in-progress', 'weekly', 1794994200, 'projects');

INSERT INTO calendar_mirrors (calendar_id, event_id, item_id, is_current)
VALUES ('personal', 'inspection', 'd', 1), ('old-calendar', 'old-event', 'd', 0);

INSERT INTO tags (id, name, is_person, created_at)
VALUES ('alice', 'Alice', 1, 1794907800), ('home-tag', 'Home', 0, 1794907801);

INSERT INTO item_tags (item_id, tag_id) VALUES ('a', 'home-tag'), ('c', 'alice');

INSERT INTO import_batches (id, fingerprint)
VALUES ('batch-1', 'fixture-fingerprint-1'), ('batch-2', 'fixture-fingerprint-2');

COMMIT;
