# Recruitment Task: Ruby on Rails Developer

A simple API for a library management system.

## Requirements
- Ruby: 4.0.7
- Rails: 8.1.4

## SQL Architecture

### books
- serial_number int
- title varchar
- author varchar
- status varchar (available, borrowed, archived)

### readers
- card_number int
- full_name varchar
- email varchar

### loans
- reader_id int
- book_id int
- status varchar (pending, active, completed)
- borrowed_at timestamp
- returned_at timestamp

## API Endpoints

- GET /v1/books
- POST /v1/books
- POST /v1/book/{id}
- DELETE /v1/book/{id}
- GET /v1/loans
