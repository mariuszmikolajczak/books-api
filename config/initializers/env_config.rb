# frozen_string_literal: true

Rails.application.config.to_prepare do
  Rails.application.config.x.book_borrow_time = ENV.fetch("BORROW_TIME", 30).to_i
  Rails.application.config.x.notification_before_due = ENV.fetch("NOTIFICATION_BEFORE_DUE", 3).to_i
end
