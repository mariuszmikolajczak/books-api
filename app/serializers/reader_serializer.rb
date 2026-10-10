# frozen_string_literal: true

class ReaderSerializer
  extend CommonMethods

  def initialize(reader) = @reader = reader

  def as_json
    {
      id: @reader.id,
      card_number: @reader.formatted_card_number,
      full_name: @reader.full_name,
      email: @reader.email
    }
  end
end
