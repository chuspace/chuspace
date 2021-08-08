# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github,
           Rails.application.credentials.github[:client_id],
           Rails.application.credentials.github[:client_secret],
           scope: 'read:user,user:email'
  provider :gitlab,
           Rails.application.credentials.gitlab[:client_id],
           Rails.application.credentials.gitlab[:client_secret],
           scope: 'read_user email profile'
  provider :bitbucket,
           Rails.application.credentials.bitbucket[:client_id],
           Rails.application.credentials.bitbucket[:client_secret],
           scope: 'email account'
end
