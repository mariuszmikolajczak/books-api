# frozen_string_literal: true

class SendReminderJob < ApplicationJob
  queue_as :default

  def perform(loan_id, kind)
    raise ArgumentError, "unknown reminder: #{kind}" unless Loan::REMINDERS.include?(kind)

    loan = Loan.find_by(id: loan_id)
    return unless loan.present?

    loan.with_lock do
      next if loan.returned_at?

      attributes = case kind
      when "due_soon"
        next if loan.due_soon_reminder_sent_at.present?

        ReminderMailer.with(loan:).due_soon.deliver_now
        {due_soon_reminder_sent_at: Time.current}
      when "due_today"
        next if loan.due_today_reminder_sent_at.present?

        ReminderMailer.with(loan:).due_today.deliver_now
        {due_today_reminder_sent_at: Time.current}
      else
        # This should never happen due to the earlier check, but we include it for completeness.
      end

      loan.update!(attributes)
    end
  end
end
