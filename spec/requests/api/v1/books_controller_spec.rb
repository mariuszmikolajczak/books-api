# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::BooksController, type: :request do
  describe "GET /api/v1/books" do
    subject(:get_request) { get api_v1_books_path }

    before do
      create_list(:book, 5)
    end

    it "returns list of books" do
      expect { get_request }.not_to raise_error
      expect(response).to have_http_status(:ok)
      expect(json["books"]).to be_an(Array)
      expect(json["books"].count).to eq(5)
    end

    context "when there are archived books" do
      before do
        create_list(:book, 3, status: "archived")
      end

      it "does not return archived books" do
        expect { get_request }.not_to raise_error
        expect(response).to have_http_status(:ok)
        expect(json["books"]).to be_an(Array)
        expect(json["books"].count).to eq(5)
      end
    end
  end

  describe "POST /api/v1/books" do
    subject(:post_request) { post(api_v1_books_path, params:) }

    let(:params) do
      {
        book: {
          serial_number: 123456,
          title: "Test Book",
          author: "Test Author"
        }
      }
    end

    it "creates a new book" do
      expect { post_request }.to change { Book.count }.by(1)
      expect(response).to have_http_status(:created)
      expect(json["serial_number"]).to eq("123456")
      expect(json["title"]).to eq("Test Book")
      expect(json["author"]).to eq("Test Author")
      expect(json["status"]).to eq("available")
    end

    context "when serial_number is not unique" do
      before do
        create(:book, serial_number: 123456)
      end

      it "returns error" do
        expect { post_request }.not_to change { Book.count }
        expect(response).to have_http_status(:unprocessable_content)
        expect(json["error"]).to eq("Serial number has already been taken")
      end
    end

    context "when missing required fields" do
      let(:params) do
        {
          book: {
            serial_number: nil,
            title: nil,
            author: nil
          }
        }
      end

      it "returns error" do
        expect { post_request }.not_to change { Book.count }
        expect(response).to have_http_status(:unprocessable_content)
        expect(json["error"]).to include("Serial number can't be blank")
        expect(json["error"]).to include("Title can't be blank")
        expect(json["error"]).to include("Author can't be blank")
      end
    end
  end

  describe "GET /api/v1/books/:serial_number" do
    subject(:get_request) { get api_v1_book_path(book.formatted_serial) }

    let!(:book) { create(:book) }

    before do
      create_list(:loan, 10, book:, returned_at: Time.current)
    end

    it "returns book details" do
      expect { get_request }.not_to raise_error
      expect(response).to have_http_status(:ok)
      expect(json["loans"].count).to eq(10)
      expect(json["serial_number"]).to eq(book.formatted_serial)
      expect(json["title"]).to eq(book.title)
      expect(json["author"]).to eq(book.author)
      expect(json["status"]).to eq(book.status)
    end
  end

  describe "DELETE /api/v1/books/:serial_number" do
    subject(:delete_request) { delete api_v1_book_path(book.formatted_serial) }

    let!(:book) { create(:book) }

    it "moves book to archive" do
      expect { delete_request }.not_to raise_error
      expect(response).to have_http_status(:ok)
      expect(book.reload.status).to eql("archived")
    end

    context "when book is borrowed" do
      let!(:book) { create(:book, status: "borrowed") }

      it "returns error" do
        expect { delete_request }.not_to raise_error
        expect(response).to have_http_status(:unprocessable_content)
        expect(json["error"]).to eq("Cannot archive a borrowed book")
      end
    end

    context "when book doesn't exist" do
      subject(:delete_request) { delete api_v1_book_path("nonexistent") }

      it "returns error" do
        expect { delete_request }.not_to raise_error
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
