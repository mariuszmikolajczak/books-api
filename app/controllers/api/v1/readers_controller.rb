# frozen_string_literal: true

class Api::V1::ReadersController < Api::V1::BaseController
  def index
    render json: {readers: ReaderSerializer.many(Reader.all)}
  end
end
