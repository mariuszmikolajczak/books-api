# frozen_string_literal: true

class Api::V1::ReadersController < Api::V1::BaseController
  def index
    render json: {readers: ReaderSerializer.many(Reader.all)}
  end

  def create
    @reader = Reader.new(reader_params)

    if @reader.save
      render json: ReaderSerializer.one(@reader), status: :created
    else
      render_error(@reader.errors.full_messages.join(", "))
    end
  end

  private

  def reader_params = params.require(:reader).permit(:card_number, :full_name, :email)
end
