class AutoChecksController < ApplicationController
  def create
    case params[:attribute].to_sym
    when :email
      perform_check(resource: User, attribute: 'email')
    when :username
      perform_check(resource: User, attribute: 'username')
    when :blog_permalink
      perform_check(resource: Blog, attribute: 'permalink')
    end
  end

  private

  def perform_check(resource:, attribute:)
    record = resource.new("#{attribute}": params[:value])

    if record.valid_attributes?(attribute)
      head :ok
    else
      render html: record.errors.messages[attribute.to_sym].to_sentence.html_safe, status: :unprocessable_entity
    end
  end
end
