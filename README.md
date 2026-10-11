# Recruitment Task: Ruby on Rails Developer

A simple API for a library management system.

[![CI](https://github.com/mariuszmikolajczak/books-api/actions/workflows/ci.yml/badge.svg)](https://github.com/mariuszmikolajczak/books-api/actions/workflows/ci.yml)
[![rspec](https://github.com/mariuszmikolajczak/books-api/actions/workflows/rspec.yml/badge.svg)](https://github.com/mariuszmikolajczak/books-api/actions/workflows/rspec.yml)
![Ruby](https://img.shields.io/badge/ruby-4.0.7-red)

## Requirements
- Ruby: 4.0.7
- Rails: 8.1.4

## Run the application

To build and start the application:
```bash
docker compose up --build
```

To run specs
```bash
docker compose run --rm web bundle exec rspec
```

To run rails console
```bash
docker compose run --rm web bin/rails c
```

To run any command
```bash
docker compose run --rm web <command>
```

## Configuration

| ENV variable            | Default              | Description                                 |
|-------------------------|----------------------|---------------------------------------------|
| BORROW_TIME             | 30                   | Loan period in days                         |
| NOTIFICATION_BEFORE_DUE | 3                    | How many days before the due date to remind |
| DEFAULT_MAILER_FROM     | no-reply@example.com | Sender address of reminder emails           |

## API Endpoints

| Method | Endpoint                       | Description                                                        |
|--------|--------------------------------|--------------------------------------------------------------------|
| GET    | `/api/v1/books`                | List books (with available / borrowed status)                      | 
| POST   | `/api/v1/books`                | Create book                                                        | 
| GET    | `/api/v1/book/{serial_number}` | Show book with full loan history, newest first (incl. reader data) | 
| DELETE | `/api/v1/book/{serial_number}` | Archive book                                                       | 
| GET    | `/api/v1/readers`              | List readers                                                       | 
| POST   | `/api/v1/readers`              | Create reader                                                      | 
| POST   | `/api/v1/loans`                | Borrow book (status → borrowed)                                    | 
| POST   | `/api/v1/loans/return`         | Return book (status → available)                                   |

## Examples

```
# Create a book and a reader
curl -X POST localhost:3000/api/v1/books -H 'Content-Type: application/json' \
  -d '{"book": {"serial_number": "000123", "title": "The Hobbit", "author": "J.R.R. Tolkien"}}'

curl -X POST localhost:3000/api/v1/readers -H 'Content-Type: application/json' \
  -d '{"reader": {"card_number": "000042", "full_name": "Jan Kowalski", "email": "jan@example.com"}}'

# Borrow and return
curl -X POST localhost:3000/api/v1/loans -H 'Content-Type: application/json' \
  -d '{"book_serial_number": "000123", "reader_card_number": "000042"}'

curl -X POST localhost:3000/api/v1/loans/return -H 'Content-Type: application/json' \
  -d '{"book_serial_number": "000123"}'

# Book details with loan history
curl localhost:3000/api/v1/books/000123
```

## Data model

### books
- `serial_number` integer, unique, 1..999 999 (rendered zero-padded as six digits)
- `title` varchar
- `author` varchar
- `status` varchar — `available`, `borrowed`, `archived`

### readers
- `card_number` integer, unique, 1..999 999 (rendered zero-padded as six digits)
- `full_name` varchar
- `email` varchar, unique, normalized to lowercase

### loans
- `reader_id` foreign key
- `book_id` foreign key
- `borrowed_at` timestamp
- `due_at` timestamp
- `returned_at` timestamp (`returned_at` IS NULL = active loan)
- `due_soon_reminder_sent_at` timestamp (NULL when reminder not sent)
- `due_today_reminder_sent_at` timestamp (NULL when reminder not sent)

## Design decisions
- Borrowing is modeled as a `Loan` record, not only status update on the `Book` resource. so the `POST /api/v1/loans` 
and `POST /api/v1/loans/return` create a Loan record and updates the Book status. Another approach would be using 
`PATCH /books/:id` which hides the Loan record creation and makes it less clear what is happening in the system.
- That leads to `Book.status` and `Loan` being redundant, but it is good practice to have a status column on the main 
resource for easier filtering and indexing.
- Deleting a book archives it (soft delete). A book with loan history cannot be hard-deleted without losing that history, 
so DELETE sets status = archived. Archived books are hidden from the list; a borrowed book cannot be archived. 
Serial numbers of archived books are not reusable — a physical serial number identifies one copy forever.
- Business logic lives in small service objects (LoanCreator, LoanReturner, NotificationScheduler) returning 
[:ok, result] / [:error, code] tuples, matched in controllers with pattern matching. Error codes are translated via I18n.
- Plain-Ruby serializers instead of a gem, just because this is a small sample project.
- Solid Queue because this is default in Rails
- Scheduler runs every 30 seconds. It only picks loans without a sent reminder, so it doesn't matter how often it runs. 
A short interval is easier to test during review.
- Missed reminders are sent later. "Due soon" checks loans due from tomorrow up to 3 days ahead, not exactly in 3 days. 
If the scheduler was down on that day, the reminder is still sent once later. "Due today" works the same way for loans 
that are already overdue.

## Known limitations
- Catch-up "due today" email for overdue loans says "ends today". Only happens when the reminder was missed on the due 
date (e.g. scheduler downtime) and is sent once, but the wording is inaccurate — a dedicated "overdue" reminder would 
be the proper fix.
- Time zone. The app runs in UTC; "today" for reminders is a UTC day. A real library would set config.time_zone to its 
local zone.
- No pagination on list endpoints.
- Validation errors are returned as a single joined string rather than a per-field structure.
- No authentication / authorization
- No database `CHECK` for the six-digit range. The range `1..999_999` for serial and card numbers is validated only in 
the models. The database enforces only things that must never break: `NOT NULL`, uniqueness and foreign keys. The 
six-digit limit is a business rule from the task, so I keep it in one place. If the library grows above one million 
books or readers, only the validation (and the `%06d` formatting) needs to change, the `integer` column is big enough. 
The downside: data written without the model (e.g. raw SQL, `update_column`) is not checked.

## Ideas for improvement
- Show the current loans (reader, borrowed_at, due_at) `GET /api/v1/loans`
- Overdue reminders and a list of overdue loans for staff.
- Loan extension (renewal) endpoint.
- Api documentation (Swagger/OpenAPI).
- Pagination (`pagy`) and filtering (by status, author, reader).
- Structured error responses ({"errors": {"field": ["message"]}}).
- Seed data for quick manual testing.
