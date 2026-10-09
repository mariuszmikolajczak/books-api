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

To install dependencies after changing the Gemfile
```bash
docker compose run --rm web bundle install
```

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
