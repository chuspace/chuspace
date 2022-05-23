# frozen_string_literal: true

class Kv < ApplicationRecord
  DATA_TYPES = %w[
    string
    boolean
    integer
    float
    date
    datetime
    json
  ].freeze

  validates :key, presence: :true, uniqueness: true
  validates :data_type, inclusion: { in: DATA_TYPES, message: "%{value} must be in #{DATA_TYPES}" }

  scope :expiring,     -> { where('expires_in IS NOT NULL') }
  scope :non_expiring, -> { where('expires_in IS NULL') }
  scope :expired,      -> { where('expires_in IS NOT NULL AND expires_in >= ?', Time.current) }

  after_create -> { Kv.expired.delete_all }

  def set_value=(value)
    write_attribute(:value, value)
    self.assign_attributes(Kv.set(key, value, data_type: data_type, expires_in: expires_in))
  end

  def unset_value
    write_attribute(:value, nil)
    self.assign_attributes(Kv.set(key, nil, data_type: data_type, expires_in: expires_in))
  end

  def clear
    Kv.delete(key)
  end

  def default
    type = ActiveRecord::Type.registry.lookup(data_type.to_sym)
    type.cast(default)
  end

  def value
    type = ActiveRecord::Type.registry.lookup(data_type.to_sym)
    type.cast(super)
  end

  class << self
    def delete(key)
      find_by(key: key).destroy
    end

    def get(key)
      find_by(key: key)&.value
    end

    def set(key, value, **options)
      upsert({ key: key, value: value, **options }, returning: %i[id key value default expires_in], unique_by: :index_kvs_on_key).last
    end
  end
end
