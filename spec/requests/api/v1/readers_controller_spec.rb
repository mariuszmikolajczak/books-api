# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ReadersController, type: :request do
  describe "GET /api/v1/readers" do
    subject(:get_request) { get api_v1_readers_path }

    before do
      create_list(:reader, 5)
    end

    it "returns list of readers" do
      expect { get_request }.not_to raise_error
      expect(response).to have_http_status(:ok)
      expect(json["readers"]).to be_an(Array)
      expect(json["readers"].count).to eq(5)
    end
  end

  describe "POST /api/v1/readers" do
    subject(:post_request) { post(api_v1_readers_path, params:) }

    let(:params) do
      {
        reader: {
          card_number: "000001",
          full_name: "Test Reader",
          email: "test@example.com"
        }
      }
    end

    it "creates a new reader" do
      expect { post_request }.to change { Reader.count }.by(1)
      expect(response).to have_http_status(:created)
      expect(json["card_number"]).to eq("000001")
      expect(json["full_name"]).to eq("Test Reader")
      expect(json["email"]).to eq("test@example.com")
    end

    context "when card_number is not unique" do
      before do
        create(:reader, card_number: 1)
      end

      it "returns error" do
        expect { post_request }.not_to change { Reader.count }
        expect(response).to have_http_status(:unprocessable_content)
        expect(json["error"]).to eq("Card number has already been taken")
      end
    end

    context "when missing required fields" do
      let(:params) do
        {
          reader: {
            card_number: nil,
            full_name: nil,
            email: nil
          }
        }
      end

      it "returns error" do
        expect { post_request }.not_to change { Reader.count }
        expect(response).to have_http_status(:unprocessable_content)
        expect(json["error"]).to include("Card number can't be blank")
        expect(json["error"]).to include("Full name can't be blank")
        expect(json["error"]).to include("Email can't be blank")
      end
    end
  end
end
