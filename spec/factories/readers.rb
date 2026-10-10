# frozen_string_literal: true

# spec/factories/readers.rb
FactoryBot.define do
  factory :reader do
    card_number { Faker::Number.unique.number(digits: 5) }
    full_name { Faker::Name.name }
    email { Faker::Internet.unique.email }
  end
end
