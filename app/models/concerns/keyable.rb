# frozen_string_literal: true

module Keyable
  extend ActiveSupport::Concern

  class_methods do
    def kv_boolean(name, key: nil, expires_in: nil, default: nil)
      kv_connection_with __method__, name, key, expires_in: expires_in, default: default
    end

    def kv_string(name, key: nil, expires_in: nil, default: nil)
      kv_connection_with __method__, name, key, expires_in: expires_in, default: default
    end

    def kv_integer(name, key: nil, expires_in: nil, default: nil)
      kv_connection_with __method__, name, key, expires_in: expires_in, default: default
    end

    def kv_float(name, key: nil, expires_in: nil, default: nil)
      kv_connection_with __method__, name, key, expires_in: expires_in, default: default
    end

    def kv_datetime(name, key: nil, expires_in: nil, default: nil)
      kv_connection_with __method__, name, key, expires_in: expires_in, default: default
    end

    def kv_date(name, key: nil, expires_in: nil, default: nil)
      kv_connection_with __method__, name, key, expires_in: expires_in, default: default
    end

    def kv_json(name, key: nil, expires_in: nil, default: nil)
      kv_connection_with __method__, name, key, expires_in: expires_in, default: default
    end

    private

    def kv_connection_with(method, name, key, expires_in:, default:)
      ivar_symbol = :"@#{name}_#{method}"
      type = method.to_s.sub('kv_', '')

      ActiveRecord::Base.connected_to(role: :writing) do
        define_method(name) do
          if instance_variable_defined?(ivar_symbol)
            instance_variable_get(ivar_symbol)
          else
            evaluated_key = kv_key_evaluated(key) || kv_key_for_attribute(name)
            expires_in = expires_in ? Time.current + expires_in : nil
            instance_variable_set(ivar_symbol, Kv.find_by(key: evaluated_key) || Kv.new(Kv.set(evaluated_key, nil, data_type: type, expires_in: expires_in, default: default)))
          end
        end
      end
    end
  end

  def kv_key_evaluated(key)
    if key && respond_to?(key, true)
      send(key)
    else
      case key
      when String then key
      when Proc   then key.call(self)
      end
    end
  end

  def kv_key_for_attribute(name)
    if respond_to?(:kv_key_prefix, true)
      "#{send(:kv_key_prefix)}:#{name}"
    else
      "#{self.class.name.tableize.gsub("/", ":")}:#{extract_kv_id}:#{name}"
    end
  end

  def extract_kv_id
    try(:id) or raise NotImplementedError, 'KV needs a unique id, either implement an id method or pass a custom key.'
  end
end
