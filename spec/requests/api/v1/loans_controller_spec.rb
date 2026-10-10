# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::LoansController, type: :request do
  describe "POST /api/v1/loans" do
    subject(:post_request) { post(api_v1_loans_path, params:) }

    let(:params) { {book_serial_number: "000001", reader_card_number: "000001"} }
    let!(:book) { create(:book, serial_number: "000001") }
    let!(:reader) { create(:reader, card_number: "000001") }

    before { freeze_time }

    it "creates a new loan" do
      expect { post_request }.to change { Loan.count }.by(1)
      expect(response).to have_http_status(:created)
      expect(json["book"]["serial_number"]).to eq("000001")
      expect(json["reader"]["card_number"]).to eq("000001")
      expect(json["borrowed_at"]).to eq(Time.current.as_json)
      expect(json["due_at"]).to eq(30.days.from_now.as_json)
    end

    after { unfreeze_time }
  end
end
