# frozen_string_literal: true

class SendNotificationJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info("############### Running SendNotificationJob")
  end
end
