# frozen_string_literal: true

require 'minitest/autorun'
require 'data_class_factory'

# rubocop:disable Metrics/AbcSize, Metrics/MethodLength
class DataTest < Minitest::Test
  # https://docs.ruby-lang.org/en/3.2/Data.html
  def test_simplest_example
    klass = Data.define(:amount, :unit)
    # Positional arguments constructor is provided
    distance = klass.new(amount: 100, unit: 'km')
    assert_equal 100, distance.amount
    assert_equal 'km', distance.unit
  end

  # https://docs.ruby-lang.org/en/3.2/Data.html
  def test_simplest_example_with_block
    klass = Data.define(:amount, :unit) do
      def <=>(other)
        return unless other.is_a?(self.class) && other.unit == unit

        amount <=> other.amount
      end

      include Comparable
    end

    assert klass.new(amount: 3, unit: 'm') < klass.new(amount: 5, unit: 'm')
  end

  # https://docs.ruby-lang.org/en/3.2/Data.html
  def test_data_class_has_no_attr_writer
    klass = Data.define(:time, :weekdays)
    event = klass.new(time: '18:00', weekdays: %w[Tue Wed Fri])
    assert !event.respond_to?(:time=)
    assert !event.respond_to?(:weekdays=)

    event.weekdays << 'Sat'
    assert event.weekdays.include?('Sat')
  end

  # https://github.com/ruby/ruby/blob/v3_2_0/test/ruby/test_data.rb
  def test_define
    klass = Data.define(:foo, :bar)
    assert_kind_of(Class, klass)
    assert_equal(%i[foo bar], klass.members)

    assert_raises(NoMethodError) { Data.new(:foo) }
    assert_raises(TypeError) { Data.define(0) }

    # Because some code is shared with Struct, check we don't share unnecessary functionality
    assert_raises(TypeError) { Data.define(:foo, keyword_init: true) }

    assert !Data.define.respond_to?(:define), 'Cannot define from defined Data class'
  end

  def test_define_edge_cases
    # non-ascii
    klass = Data.define(:"r\u{e9}sum\u{e9}")
    o = klass.new("r\u{e9}sum\u{e9}": 1)
    assert_equal(1, o.send(:"r\u{e9}sum\u{e9}"))

    # junk string
    klass = Data.define(:"a\000")
    o = klass.new("a\000": 1)
    assert_equal(1, o.send(:"a\000"))

    # special characters in attribute names
    klass = Data.define(:a, :b?)
    x = Object.new
    o = klass.new(a: 'test', b?: x)
    assert_same(x, o.b?)

    klass = Data.define(:a, :b!)
    x = Object.new
    o = klass.new(a: 'test', b!: x)
    assert_same(x, o.b!)

    assert_raises(ArgumentError) { Data.define(:x=) }
    err = assert_raises(ArgumentError) { Data.define(:x, :x) }
    assert_match(/duplicate member/, err.message)
  end

  def test_define_with_block
    klass = Data.define(:a, :b) do
      def c
        a + b
      end
    end

    assert_equal(3, klass.new(a: 1, b: 2).c)
  end

  def test_initialize
    klass = Data.define(:foo, :bar)

    test_kw = klass.new(foo: 1, bar: 2)
    assert_equal(1, test_kw.foo)
    assert_equal(2, test_kw.bar)
    assert_equal(test_kw, klass.new(foo: 1, bar: 2))

    # Wrong protocol
    assert_raises(ArgumentError) { klass.new(1) }
    assert_raises(ArgumentError) { klass.new(1, 2) }
    assert_raises(ArgumentError) { klass.new(1, 2, 3) }
    assert_raises(ArgumentError) { klass.new(foo: 1) }
    assert_raises(ArgumentError) { klass.new(foo: 1, bar: 2, baz: 3) }
    # Could be converted to foo: 1, bar: 2, but too smart is confusing
    assert_raises(ArgumentError) { klass.new(1, bar: 2) }
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength
