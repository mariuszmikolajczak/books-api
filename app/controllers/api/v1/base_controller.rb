# frozen_string_literal: true

class Api::V1::BaseController < ApplicationController
  def render_error(message = nil, status = :unprocessable_content)
    if message.nil?
      head status
    else
      render json: {error: message}, status: status
    end
  end
end
