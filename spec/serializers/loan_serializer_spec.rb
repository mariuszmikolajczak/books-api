# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoanSerializer, type: :serializer do
  subject(:loan_serializer) { described_class.new(loan) }

  let(:loan) { create(:loan) }

  it "serializes a loan correctly" do
    expect(loan_serializer.as_json).to eql({
      id: loan.id,
      book: BookSerializer.one(loan.book),
      reader: ReaderSerializer.one(loan.reader),
      borrowed_at: loan.borrowed_at,
      due_at: loan.due_at,
      returned_at: loan.returned_at
    })
  end

  context "when using static method" do
    subject { described_class }

    let(:resource) { create(:loan) }
    let(:resources) { create_list(:loan, 3) }

    include_examples "common methods"
  end
end
