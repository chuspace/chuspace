# frozen_string_literal: true

Rails.application.config.permissions_policy do |permission|
  permission.camera      :none
  permission.gyroscope   :none
  permission.microphone  :none
  permission.usb         :none
  permission.fullscreen  :self
  permission.payment     :none
end
