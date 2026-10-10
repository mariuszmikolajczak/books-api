# frozen_string_literal: true

FactoryBot.define do
  factory :loan do
    book
    reader
    borrowed_at { Faker::Date.backward(days: 14) }
    due_at { Faker::Date.forward(days: 30) }
    returned_at { nil }

    trait :returned do
      returned_at { Time.current }
    end
  end
end
