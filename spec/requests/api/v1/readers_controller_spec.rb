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
end
