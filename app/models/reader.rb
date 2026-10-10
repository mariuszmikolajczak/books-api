# frozen_string_literal: true

class Reader < ApplicationRecord
  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :full_name, with: ->(name) { name.squish }

  validates :card_number, presence: true, uniqueness: true, numericality: {only_integer: true, greater_than: 0}
  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: {case_sensitive: false}, format: {with: URI::MailTo::EMAIL_REGEXP}
end
