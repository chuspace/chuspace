# frozen_string_literal: true

module Immutable
  extend ActiveSupport::Concern

  included do
    class UpdateNotAllowedError < StandardError; end
    before_save :check_immutability
  end

  def update_column(*)
    self.class.raise_immutable_error
  end

  alias update_columns update_column

  class_methods do
    def update_all(*)
      raise_immutable_error
    end

    def raise_immutable_error
      fail UpdateNotAllowedError, 'Revisions are immutable'
    end
  end

  private

  def check_immutability
    self.class.raise_immutable_error if persisted?
  end
end
