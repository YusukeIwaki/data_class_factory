# frozen_string_literal: true

require 'minitest/autorun'
require 'data_class_factory'

# rubocop:disable Metrics/AbcSize, Metrics/ClassLength, Metrics/MethodLength
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

  # https://docs.ruby-lang.org/en/3.2/Data.html#method-i-deconstruct
  def test_deconstruct
    klass = Data.define(:amount, :unit)

    distance = klass.new(amount: 10, unit: 'km')
    assert_equal([10, 'km'], distance.deconstruct)

    # usage
    case distance
    in n, 'km' # calls #C underneath
      assert_equal 10, n
    else
      raise 'Something is wrong: #deconstruct'
    end
  end

  # https://docs.ruby-lang.org/en/3.2/Data.html#method-i-deconstruct_keys
  def test_deconstruct_keys
    klass = Data.define(:amount, :unit)

    distance = klass.new(amount: 10, unit: 'km')
    assert_equal({ amount: 10, unit: 'km' }, distance.deconstruct_keys(nil))
    assert_equal({ amount: 10 }, distance.deconstruct_keys([:amount]))

    # usage
    case distance
    in amount:, unit: 'km' # calls #deconstruct_keys underneath
      assert_equal 10, amount
    else
      raise 'Something is wrong: #deconstruct_keys'
    end
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
    assert_raises(ArgumentError) { klass.new(1, 2) } if DataClassFactory.backport?
    assert_raises(ArgumentError) { klass.new(1, 2, 3) }
    assert_raises(ArgumentError) { klass.new(foo: 1) }
    assert_raises(ArgumentError) { klass.new(foo: 1, bar: 2, baz: 3) }
    # Could be converted to foo: 1, bar: 2, but too smart is confusing
    assert_raises(ArgumentError) { klass.new(1, bar: 2) }
  end

  def test_initialize_redefine
    klass = Data.define(:foo, :bar) do
      attr_reader :passed

      def initialize(*args, **kwargs)
        @passed = [args, kwargs]
        super(foo: 1, bar: 2) # so we can experiment with passing wrong numbers of args
      end
    end

    assert_equal([[], { foo: 1, bar: 2 }], klass.new(foo: 1, bar: 2).passed)

    # Positional arguments are converted to keyword ones
    assert_equal([[], { foo: 1, bar: 2 }], klass.new(1, 2).passed) unless DataClassFactory.backport?

    # Missing arguments can be fixed in initialize
    assert_equal([[], { foo: 1 }], klass.new(foo: 1).passed)

    # Extra keyword arguments can be dropped in initialize
    assert_equal([[], { foo: 1, bar: 2, baz: 3 }], klass.new(foo: 1, bar: 2, baz: 3).passed)
  end

  def test_instance_behavior
    klass = Data.define(:foo, :bar)

    test = klass.new(foo: 1, bar: 2)
    assert_equal(1, test.foo)
    assert_equal(2, test.bar)
    assert_equal(%i[foo bar], test.members)
    assert_equal(1, test.public_send(:foo))
    assert_equal(0, test.method(:foo).arity)
    assert_equal([], test.method(:foo).parameters)

    assert_equal({ foo: 1, bar: 2 }, test.to_h)
    assert_equal({ 'foo' => '1', 'bar' => '2' }, test.to_h { [_1.to_s, _2.to_s] })

    assert_equal({ foo: 1, bar: 2 }, test.deconstruct_keys(nil))
    assert_equal({ foo: 1 }, test.deconstruct_keys(%i[foo]))
    assert_equal({ foo: 1 }, test.deconstruct_keys(%i[foo baz]))
    assert_raises(TypeError) { test.deconstruct_keys(0) }

    assert_kind_of(Integer, test.hash)
  end

  def test_inspect
    klass = Data.define(:a)
    o = klass.new(a: 1)
    assert_equal('#<data a=1>', o.inspect)

    Object.const_set(:Foo, klass)
    assert_equal('#<data Foo a=1>', o.inspect)
    Object.instance_eval { remove_const(:Foo) }

    klass = Data.define(:@a)
    o = klass.new(:@a => 1)
    assert_equal('#<data :@a=1>', o.inspect)
  end

  def test_equal
    klass1 = Data.define(:a)
    klass2 = Data.define(:a)
    o1 = klass1.new(a: 1)
    o2 = klass1.new(a: 1)
    o21 = klass1.new(a: 1.0)
    o22 = klass1.new(a: 2)
    o3 = klass2.new(a: 1)
    assert_equal(o1, o2)
    assert_equal(o1, o21)
    assert o1 != o22
    assert o1 != o3
  end

  def test_eql
    klass1 = Data.define(:a)
    klass2 = Data.define(:a)
    o1 = klass1.new(a: 1)
    o2 = klass1.new(a: 1)
    o21 = klass1.new(a: 1.0)
    o22 = klass1.new(a: 2)
    o3 = klass2.new(a: 1)
    assert_operator(o1, :eql?, o2)
    assert !o1.eql?(o21)
    assert !o1.eql?(o22)
    assert !o1.eql?(o3)
  end

  def test_with
    klass = Data.define(:foo, :bar)
    source = klass.new(foo: 1, bar: 2)

    # Simple
    test = source.with
    assert_equal(source.object_id, test.object_id)

    # Changes
    test = source.with(foo: 10)

    assert_equal(1, source.foo)
    assert_equal(2, source.bar)
    assert_equal(source, klass.new(foo: 1, bar: 2))

    assert_equal(10, test.foo)
    assert_equal(2, test.bar)
    assert_equal(test, klass.new(foo: 10, bar: 2))

    test = source.with(foo: 10, bar: 20)

    assert_equal(1, source.foo)
    assert_equal(2, source.bar)
    assert_equal(source, klass.new(foo: 1, bar: 2))

    assert_equal(10, test.foo)
    assert_equal(20, test.bar)
    assert_equal(test, klass.new(foo: 10, bar: 20))

    # Keyword splat
    changes = { foo: 10, bar: 20 }
    test = source.with(**changes)

    assert_equal(1, source.foo)
    assert_equal(2, source.bar)
    assert_equal(source, klass.new(foo: 1, bar: 2))

    assert_equal(10, test.foo)
    assert_equal(20, test.bar)
    assert_equal(test, klass.new(foo: 10, bar: 20))

    # Wrong protocol
    err = assert_raises(ArgumentError) do
      source.with(10)
    end
    assert "wrong number of arguments (given 1, expected 0)", err.message
    err = assert_raises(ArgumentError) do
      source.with(foo: 1, bar: 2, baz: 3, quux: 4)
    end
    assert "unknown keywords: :baz, :quux", err.message
    err = assert_raises(ArgumentError) do
      source.with(1, bar: 2)
    end
    assert "wrong number of arguments (given 1, expected 0)", err.message
    err = assert_raises(ArgumentError) do
      source.with(1, 2)
    end
    assert "wrong number of arguments (given 2, expected 0)", err.message
    if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.0.0')
      err = assert_raises(ArgumentError) do
        source.with({ bar: 20 })
      end
      assert "wrong number of arguments (given 1, expected 0)", err.message
    end
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/ClassLength, Metrics/MethodLength
