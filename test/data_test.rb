# frozen_string_literal: true

require 'minitest/autorun'
require 'data_class_factory'

class DataTest < Minitest::Test
  # https://docs.ruby-lang.org/en/3.2/Data.html
  def test_simplest_example
    measureClass = Data.define(:amount, :unit)
    # Positional arguments constructor is provided
    distance = measureClass.new(amount: 100, unit: 'km')
    assert_equal 100, distance.amount
    assert_equal 'km', distance.unit
  end

  # https://docs.ruby-lang.org/en/3.2/Data.html
  def test_simplest_example_with_block
    measureClass = Data.define(:amount, :unit) do
      def <=>(other)
        return unless other.is_a?(self.class) && other.unit == unit
        amount <=> other.amount
      end

      include Comparable
    end

    assert measureClass.new(amount: 3, unit: 'm') < measureClass.new(amount: 5, unit: 'm')
    err = assert_raises(ArgumentError) do
      measureClass.new(amount: 3, unit: 'm') < measureClass.new(amount: 5, unit: 'kg')
    end
    assert err.message =~ /comparison of .* failed/
  end

  # https://docs.ruby-lang.org/en/3.2/Data.html
  def test_data_class_has_no_attr_writer
    eventClass = Data.define(:time, :weekdays)
    event = eventClass.new(time: '18:00', weekdays: %w[Tue Wed Fri])
    assert !event.respond_to?(:time=)
    assert !event.respond_to?(:weekdays=)

    event.weekdays << 'Sat'
    assert event.weekdays.include?('Sat')
  end
end
