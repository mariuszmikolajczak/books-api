# frozen_string_literal: true

class ReminderMailer < ApplicationMailer
  before_action { @loan = params[:loan] }
  default to: -> { email_address_with_name(@loan.reader.email, @loan.reader.full_name) }

  def due_soon = mail(subject: default_i18n_subject(title: @loan.book.title, days:))

  def due_today = mail(subject: default_i18n_subject(title: @loan.book.title))

  private

  def days = Rails.application.config.x.notification_before_due
end
