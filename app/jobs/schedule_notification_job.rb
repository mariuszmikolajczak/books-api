# frozen_string_literal: true

class ScheduleNotificationJob < ApplicationJob
  queue_as :default

  def perform = NotificationScheduler.call
end
