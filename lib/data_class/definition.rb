# frozen_string_literal: true

require 'set'

module DataClass
  # An internal class for providing validation of `Data.define` and its initializer.
  class Definition
    # @param attribute_names [Array<Symbol>]
    def initialize(attribute_names)
      validate_attribute_names(attribute_names)
      @attribute_names = attribute_names
    end
    attr_reader :attribute_names

    # @param kwargs [Hash<Symbol, Object>]
    def validate(kwargs)
      if attribute_names - kwargs.keys != []
        raise ArgumentError, "missing keyword: #{(attribute_names - kwargs.keys).join(', ')}"
      end

      if kwargs.keys - attribute_names != []
        raise ArgumentError, "unknown keyword: #{(kwargs.keys - attribute_names).join(', ')}"
      end

      nil
    end

    private

    def validate_attribute_names(attribute_names)
      checked = Set.new
      attribute_names.each do |key|
        raise TypeError, "#{key} is not a symbol" unless key.is_a?(Symbol)
        raise ArgumentError, "invalid data member: #{key}" if key.end_with?('=')
        raise ArgumentError, "duplicate member: #{key}" if checked.include?(key)

        checked << key
      end
    end
  end
end
