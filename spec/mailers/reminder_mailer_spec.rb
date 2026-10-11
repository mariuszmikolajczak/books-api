# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReminderMailer, type: :mailer do
  let(:loan) { create(:loan) }

  describe "due_soon" do
    subject(:mail) { ReminderMailer.with(loan:).due_soon }

    it "renders the headers" do
      expect(mail.subject).to eq("Reminder: \"#{loan.book.title}\" is due in #{Rails.application.config.x.notification_before_due} days")
      expect(mail.to).to eq([loan.reader.email])
      expect(mail.from).to eq([Rails.application.config.x.default_mailer_from])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Just a friendly reminder")
    end
  end

  describe "due_today" do
    subject(:mail) { ReminderMailer.with(loan:).due_today }

    it "renders the headers" do
      expect(mail.subject).to eq("Reminder: \"#{loan.book.title}\" is due today")
      expect(mail.to).to eq([loan.reader.email])
      expect(mail.from).to eq([Rails.application.config.x.default_mailer_from])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Your loan of")
    end
  end
end
