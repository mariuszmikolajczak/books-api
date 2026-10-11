# frozen_string_literal: true

class Api::BaseController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound do |exception|
    render_error(exception.message, :not_found)
  end

  rescue_from ActionController::ParameterMissing do |exception|
    render_error(exception.message, :bad_request)
  end

  private

  def render_error(message = nil, status = :unprocessable_content)
    if message.nil?
      head status
    else
      render json: {error: message}, status: status
    end
  end
end
