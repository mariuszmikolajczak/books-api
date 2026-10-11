# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotificationScheduler do
  subject(:call) { described_class.call }

  let(:now) { Time.zone.local(2026, 10, 11, 8, 0) }
  let(:days_before_due) { 3 }

  around { |example| travel_to(now) { example.run } }

  before do
    allow(Rails.application.config.x).to receive(:notification_before_due).and_return(days_before_due)
  end

  describe "due today reminders" do
    it "enqueues due_today for loan due later today" do
      loan = create(:loan, due_at: now.end_of_day)

      expect { call }.to have_enqueued_job(SendReminderJob).with(loan.id, "due_today")
    end

    it "enqueues due_today for overdue loan" do
      loan = create(:loan, due_at: now - 1.day)

      expect { call }.to have_enqueued_job(SendReminderJob).with(loan.id, "due_today")
    end

    context "when scheduler runs long after due date" do
      let(:now) { Time.zone.local(2026, 11, 12, 8, 0) }

      it "still enqueues due_today for loan due on 30.10" do
        loan = create(:loan, borrowed_at: Time.zone.local(2026, 10, 1, 12, 0), due_at: Time.zone.local(2026, 10, 30, 12, 0))

        expect { call }.to have_enqueued_job(SendReminderJob).with(loan.id, "due_today")
      end
    end

    it "skips loan due tomorrow" do
      create(:loan, due_at: now.tomorrow.beginning_of_day)

      expect { call }.not_to have_enqueued_job(SendReminderJob).with(anything, "due_today")
    end
  end

  describe "due soon reminders" do
    it "enqueues due_soon for loan due tomorrow" do
      loan = create(:loan, due_at: now.tomorrow.beginning_of_day)

      expect { call }.to have_enqueued_job(SendReminderJob).with(loan.id, "due_soon")
    end

    it "enqueues due_soon for loan due on last day of window" do
      loan = create(:loan, due_at: (now + days_before_due.days).end_of_day)

      expect { call }.to have_enqueued_job(SendReminderJob).with(loan.id, "due_soon")
    end

    it "skips loan due after the window" do
      create(:loan, due_at: (now + (days_before_due + 1).days).beginning_of_day)

      expect { call }.not_to have_enqueued_job(SendReminderJob).with(anything, "due_soon")
    end

    it "skips loan due today" do
      create(:loan, due_at: now.end_of_day)

      expect { call }.not_to have_enqueued_job(SendReminderJob).with(anything, "due_soon")
    end

    it "skips overdue loan" do
      create(:loan, due_at: now - 1.day)

      expect { call }.not_to have_enqueued_job(SendReminderJob).with(anything, "due_soon")
    end
  end

  context "with inactive loan" do
    it "sends no reminders" do
      create(:loan, :returned, due_at: now - 1.day)

      expect { call }.not_to have_enqueued_job(SendReminderJob)
    end
  end

  context "when reminder already sent" do
    it "skips due_today reminder" do
      loan = create(:loan, due_at: now.end_of_day, due_today_reminder_sent_at: now - 1.hour)

      expect { call }.not_to have_enqueued_job(SendReminderJob).with(loan.id, "due_today")
    end

    it "skips due_soon reminder" do
      loan = create(:loan, due_at: now.tomorrow.beginning_of_day, due_soon_reminder_sent_at: now - 1.hour)

      expect { call }.not_to have_enqueued_job(SendReminderJob).with(loan.id, "due_soon")
    end
  end
end
