# frozen_string_literal: true

require_relative '../../app/models/server_side_session.rb'

Rails.application.config.session_store :active_record_store, key: '_chuspace_global_session'
ActionDispatch::Session::ActiveRecordStore.session_class = ServerSideSession
