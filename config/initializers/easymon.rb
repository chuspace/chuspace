# frozen_string_literal: true

Easymon::Repository.add(
  'application-database-replica',
  Easymon::ActiveRecordCheck.new(ActiveRecord::Base),
  :critical
)

ActiveRecord::Base.connected_to(role: :writing) do
  Easymon::Repository.add(
    'application-database',
    Easymon::ActiveRecordCheck.new(ActiveRecord::Base),
    :critical
  )
end

Easymon::Repository.add(
  'memcached',
  Easymon::MemcachedCheck.new(Rails.cache),
  :critical
)
