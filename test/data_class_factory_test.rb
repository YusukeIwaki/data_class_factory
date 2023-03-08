# frozen_string_literal: true

require 'minitest/autorun'
require 'data_class_factory'

class DataClassFactoryTest < Minitest::Test
  MyDataClass = DataClassFactory.define_factory_class
  def test_factory_with_another_name
    klass = MyDataClass.define(:foo, :bar)
    value = klass.new(foo: 1, bar: 2)
    assert_equal 1, value.foo
    assert_equal 2, value.bar
  end
end
