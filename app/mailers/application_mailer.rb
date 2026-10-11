# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.config.x.default_mailer_from
  layout "mailer"
end
