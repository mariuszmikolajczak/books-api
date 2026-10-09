# frozen_string_literal: true

class Book < ApplicationRecord
  STATUSES = %w[available borrowed archived].freeze

  validates :serial_number, presence: true, uniqueness: true, numericality: {only_integer: true, greater_than: 0}
  validates :title, presence: true
  validates :author, presence: true
  validates :status, presence: true, inclusion: {in: STATUSES}

  enum :status, STATUSES.index_by(&:to_sym), validate: true

  scope :not_archived, -> { where(status: "available") }

  def formatted_serial = format("%06d", serial_number)
end
