# frozen_string_literal: true

class SendNotificationJob < ApplicationJob
  queue_as :default

  def perform = NotificationScheduler.call
end
