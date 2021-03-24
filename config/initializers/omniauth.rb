# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github,
           Rails.application.credentials.github[:client_id],
           Rails.application.credentials.github[:client_secret],
           scope: 'user,repo,admin:public_key'
  provider :gitlab,
           Rails.application.credentials.gitlab[:client_id],
           Rails.application.credentials.gitlab[:client_secret],
           scope: 'read_user read_repository write_repository email profile'
           {
             client_options: {
              site: 'https://gitlab.YOURDOMAIN.com/api/v4'
             }
           }
end
