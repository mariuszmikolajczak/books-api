# frozen_string_literal: true

class NotificationScheduler
  def self.call = new.call

  def call
    Rails.logger.info("NotificationScheduler started at #{Time.zone.now}")
    reminder_due_today
    reminder_due_soon
    Rails.logger.info("NotificationScheduler finished at #{Time.zone.now}")
  end

  private

  def reminder_due_soon
    Loan.active.where(due_at: due_soon_range).find_each do |loan|
      SendReminderJob.perform_later(loan.id, "due_soon")
    end
  end

  def reminder_due_today
    Loan.active.where(due_at: ..Time.zone.now.end_of_day).find_each do |loan|
      SendReminderJob.perform_later(loan.id, "due_today")
    end
  end

  def due_soon_range
    Time.zone.now.tomorrow.beginning_of_day..days_before_due.days.from_now.end_of_day
  end

  def days_before_due = Rails.application.config.x.notification_before_due
end
