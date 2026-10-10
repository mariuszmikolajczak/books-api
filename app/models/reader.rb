# frozen_string_literal: true

class Reader < ApplicationRecord
  has_many :loans, dependent: :restrict_with_error

  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :full_name, with: ->(name) { name.squish }

  validates :card_number, presence: true, uniqueness: true, numericality: {only_integer: true, greater_than: 0}
  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: {case_sensitive: false}, format: {with: URI::MailTo::EMAIL_REGEXP}

  def formatted_card_number = format("%06d", card_number)
end
