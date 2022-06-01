# frozen_string_literal: true

require_relative '../../app/models/server_side_session.rb'

Rails.application.config.session_store(
  :active_record_store,
  domain: :all,
  secure: Rails.env.produdction?,
  serializer: :json,
  key: '_chuspace_app_global_session'
)

ActionDispatch::Session::ActiveRecordStore.session_class = ServerSideSession
