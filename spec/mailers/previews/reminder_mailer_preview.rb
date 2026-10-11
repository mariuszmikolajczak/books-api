# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/reminder_mailer
class ReminderMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/reminder_mailer/due_soon
  def due_soon = ReminderMailer.with(loan: sample_loan(soon_days.days.from_now)).due_soon

  # Preview this email at http://localhost:3000/rails/mailers/reminder_mailer/due_today
  def due_today = ReminderMailer.with(loan: sample_loan(Date.current)).due_today

  private

  def sample_loan(due_at)
    Loan.new(
      due_at: due_at.to_date,
      book: Book.new(title: "The Hobbit"),
      reader: Reader.new(full_name: "Jan Kowalski", email: "jan@example.com")
    )
  end

  def soon_days = Rails.application.config.x.notification_before_due
end
