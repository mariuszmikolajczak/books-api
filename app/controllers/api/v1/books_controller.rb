# frozen_string_literal: true

class Api::V1::BooksController < Api::V1::BaseController
  before_action :load_book, only: %i[show destroy]

  def index
    render json: BookSerializer.many(Book.all)
  end

  def show
  end

  def create
    @book = Book.new(book_params)

    if @book.save
      render json: BookSerializer.one(@book), status: :created
    else
      render_error(@book.errors.full_messages.join(", "))
    end
  end

  def destroy
    if @book.update(status: "archived")
      head :ok
    else
      render_error(@book.errors.full_messages.join(", "))
    end
  end

  private

  def load_book = @book = Book.find(params[:id])

  def book_params = params.require(:book).permit(:serial_number, :title, :author)
end
