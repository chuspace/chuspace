# frozen_string_literal: true

require 'test_helper'

class KvTest < ActiveSupport::TestCase
  def setup
    @kv = build(:kv)
  end

  def test_validations
    assert @kv.valid?
    @kv.value = nil
    assert @kv.valid?
    @kv.key = nil
    refute @kv.valid?
    @kv.key = 'foo'
    @kv.data_type = :binary
    refute @kv.valid?
  end

  def test_kv_actions
    refute @kv.id
    @kv.set_value = 'foo'
    assert_equal 'foo', @kv.value
    assert @kv.id

    @kv.unset_value
    assert_nil @kv.value
  end
end
