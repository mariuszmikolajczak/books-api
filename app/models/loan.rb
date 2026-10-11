# frozen_string_literal: true

class Loan < ApplicationRecord
  REMINDERS = %w[due_soon due_today].freeze

  belongs_to :book
  belongs_to :reader

  scope :active, -> { where(returned_at: nil) }
  scope :due_soon_reminder_not_sent, -> { where(due_soon_reminder_sent_at: nil) }
  scope :due_today_reminder_not_sent, -> { where(due_today_reminder_sent_at: nil) }

  validates :borrowed_at, presence: true
  validates :due_at, presence: true
  validates :book_id, uniqueness: {conditions: -> { active }, message: :already_borrowed}, if: -> { returned_at.nil? }
  validate :due_date_after_borrowed_date

  private

  def due_date_after_borrowed_date
    return if due_at.blank? || borrowed_at.blank?

    errors.add(:due_at, :after_borrowed_date) if due_at <= borrowed_at
  end
end
