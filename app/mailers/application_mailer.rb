# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@mail.chuspace.com'
  layout 'mailer'
end
