# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendNotificationJob, type: :job do
  describe "#perform" do
    it "calls NotificationScheduler" do
      allow(NotificationScheduler).to receive(:call)

      described_class.perform_now

      expect(NotificationScheduler).to have_received(:call).once
    end
  end

  describe ".perform_later" do
    it "enqueues the job on the default queue" do
      expect { described_class.perform_later }
        .to have_enqueued_job(described_class).on_queue("default")
    end
  end
end
