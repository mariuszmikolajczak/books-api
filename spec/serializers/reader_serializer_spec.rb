# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReaderSerializer, type: :serializer do
  subject(:reader_serializer) { described_class.new(reader) }

  let(:reader) { create(:reader) }

  it "serializes a reader correctly" do
    expect(reader_serializer.as_json).to eql({
      id: reader.id,
      card_number: reader.formatted_card_number,
      full_name: reader.full_name,
      email: reader.email
    })
  end

  context "when using static method" do
    subject { described_class }

    let(:resource) { create(:reader) }
    let(:resources) { create_list(:reader, 3) }

    include_examples "common methods"
  end
end
