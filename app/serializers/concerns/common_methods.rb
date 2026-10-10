# frozen_string_literal: true

module CommonMethods
  def many(resources) = resources.map { new(it).as_json }

  def one(resource) = new(resource).as_json
end
