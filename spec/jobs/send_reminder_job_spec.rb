# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendReminderJob, type: :job do
  let(:loan) { create(:loan) }

  describe "#perform" do
    describe "#due_soon" do
      subject { described_class.perform_now(loan.id, "due_soon") }

      it "calls ReminderMailer" do
        allow(ReminderMailer).to receive_message_chain(:with, :due_soon, :deliver_now)

        subject

        expect(ReminderMailer).to have_received(:with).once
        expect(loan.reload.due_soon_reminder_sent_at).not_to be_nil
      end
    end

    describe "#due_today" do
      subject { described_class.perform_now(loan.id, "due_today") }

      it "calls ReminderMailer" do
        allow(ReminderMailer).to receive_message_chain(:with, :due_today, :deliver_now)

        subject

        expect(ReminderMailer).to have_received(:with).once
        expect(loan.reload.due_today_reminder_sent_at).not_to be_nil
      end
    end
  end

  describe ".perform_later" do
    it "enqueues the job on the default queue due_soon" do
      expect { described_class.perform_later(loan.id, "due_soon") }
        .to have_enqueued_job(described_class).on_queue("default")
    end

    it "enqueues the job on the default queue due_today" do
      expect { described_class.perform_later(loan.id, "due_today") }
        .to have_enqueued_job(described_class).on_queue("default")
    end
  end
end
