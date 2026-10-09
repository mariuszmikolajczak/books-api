# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::BooksController, type: :request do
  describe "GET /api/v1/books" do
    subject(:get_request) { get api_v1_books_path }

    before do
      create_list(:book, 5)
    end

    it "returns list of books" do
      expect { get_request }.not_to raise_error
      expect(response).to have_http_status(:ok)
      expect(json).to be_an(Array)
      expect(json.count).to eq(5)
    end

    context "when there are archived books" do
      before do
        create_list(:book, 3, status: "archived")
      end

      it "does not return archived books" do
        expect { get_request }.not_to raise_error
        expect(response).to have_http_status(:ok)
        expect(json).to be_an(Array)
        expect(json.count).to eq(5)
      end
    end
  end

  describe "DELETE /api/v1/books/:id" do
    subject(:delete_request) { delete api_v1_book_path(book.id) }

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
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]).to eq("Cannot archive a borrowed book")
      end
    end
  end
end
