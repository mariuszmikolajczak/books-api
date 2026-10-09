# frozen_string_literal: true

module RequestHelpers
  def json = response.parsed_body
end
