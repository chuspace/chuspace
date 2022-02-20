# frozen_string_literal: true

module Immutable
  extend ActiveSupport::Concern

  included do
    class UpdateNotAllowedError < StandardError; end
    before_update :raise_immutable_error
  end

  def update(*)
    raise_immutable_error
  end

  alias update! update
  alias update_column update

  class_methods do
    def update_all(*)
      raise_immutable_error
    end

    def raise_immutable_error
      fail UpdateNotAllowedError, 'Revisions are immutable'
    end
  end

  private

  def raise_immutable_error
    self.class.raise_immutable_error
  end
end
