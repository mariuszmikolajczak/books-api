FactoryBot.define do
  factory :book do
    serial_number { Faker::Number.unique.number(digits: 5) }
    title { Faker::Book.title }
    author { Faker::Book.author }
    status { "available" }
  end
end
