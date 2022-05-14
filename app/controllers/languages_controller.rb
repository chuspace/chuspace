# frozen_string_literal: true

class LanguagesController < ApplicationController
  skip_verify_authorized

  def index
    @languages = Language.all
    render json: @languages.to_json
  end

  def show
    language = Language.find(params[:id])
    render json: language.to_json
  end
end
