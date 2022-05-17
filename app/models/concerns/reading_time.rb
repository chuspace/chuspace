# frozen_string_literal: true

module ReadingTime
  extend ActiveSupport::Concern

  WORDS_PER_MINUTE = 238

  def words_count
    body.scan(/\w+/).size || 0
  end

  def reading_time
    words_count > WORDS_PER_MINUTE ? (words_count / WORDS_PER_MINUTE).round : 1
  end
end
