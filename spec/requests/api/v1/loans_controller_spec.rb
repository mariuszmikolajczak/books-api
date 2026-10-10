# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::LoansController, type: :request do
  before { freeze_time }

  shared_context "bad params" do
    context "when wrong parameters are provided" do
      let(:params) { {wrong: :params, provided: :to_controller} }

      it "returns an error response" do
        expect { post_request }.not_to raise_error
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe "POST /api/v1/loans" do
    subject(:post_request) { post(api_v1_loans_path, params:) }

    let(:params) { {book_serial_number: "000001", reader_card_number: "000001"} }
    let!(:book) { create(:book, serial_number: "000001") }
    let!(:reader) { create(:reader, card_number: "000001") }

    it "creates a new loan" do
      expect { post_request }.to change { Loan.count }.by(1)
      expect(response).to have_http_status(:created)
      expect(json["book"]["serial_number"]).to eq("000001")
      expect(json["reader"]["card_number"]).to eq("000001")
      expect(json["borrowed_at"]).to eq(Time.current.as_json)
      expect(json["due_at"]).to eq(30.days.from_now.as_json)
    end

    include_context "bad params"

    context "when book is not found" do
      let(:params) { {book_serial_number: "000002", reader_card_number: "000001"} }

      it "returns an error response" do
        expect { post_request }.not_to raise_error
        expect(response).to have_http_status(:unprocessable_content)
        expect(json["error"]).to eq("Book not found")
      end
    end

    context "when reader is not found" do
      let(:params) { {book_serial_number: "000001", reader_card_number: "000002"} }

      it "returns an error response" do
        expect { post_request }.not_to raise_error
        expect(response).to have_http_status(:unprocessable_content)
        expect(json["error"]).to eq("Reader not found")
      end
    end

    context "when book already borrowed" do
      let!(:book) { create(:book, serial_number: "000001", status: :borrowed) }

      it "returns an error response" do
        expect { post_request }.not_to raise_error
        expect(response).to have_http_status(:unprocessable_content)
        expect(json["error"]).to eq("Book is already borrowed")
      end
    end

    context "when an exception occurs" do
      before do
        allow(LoanCreator).to receive(:call).and_return([:exception, "Unexpected error"])
      end

      it "returns an error response" do
        expect { post_request }.not_to raise_error
        expect(response).to have_http_status(:internal_server_error)
        expect(json["error"]).to eq("Unexpected error")
      end
    end
  end

  describe "POST /api/v1/loans/return" do
    subject(:post_request) { post(return_api_v1_loans_path, params:) }

    let(:params) { {book_serial_number: "000001"} }
    let!(:book) { create(:book, serial_number: "000001", status: :borrowed) }
    let!(:loan) { create(:loan, book:) }

    it "creates a new loan" do
      expect { post_request }.not_to raise_error
      expect(response).to have_http_status(:no_content)
      expect(book.reload.status).to eq("available")
      expect(loan.reload.returned_at).to eq(Time.current)
    end

    include_context "bad params"

    context "when book is not found" do
      let(:params) { {book_serial_number: "000002"} }

      it "returns an error response" do
        expect { post_request }.not_to raise_error
        expect(response).to have_http_status(:unprocessable_content)
        expect(json["error"]).to eq("Book not found")
      end
    end

    context "when book available" do
      let!(:book) { create(:book, serial_number: "000001", status: :available) }

      it "returns an error response" do
        expect { post_request }.not_to raise_error
        expect(response).to have_http_status(:unprocessable_content)
        expect(json["error"]).to eq("No active loan found for this book")
      end
    end

    context "when an exception occurs" do
      before do
        allow(LoanReturner).to receive(:call).and_return([:exception, "Unexpected error"])
      end

      it "returns an error response" do
        expect { post_request }.not_to raise_error
        expect(response).to have_http_status(:internal_server_error)
        expect(json["error"]).to eq("Unexpected error")
      end
    end
  end

  after { unfreeze_time }
end
