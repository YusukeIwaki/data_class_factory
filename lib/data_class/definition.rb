# frozen_string_literal: true

module DataClass
  # An internal class for providing validation of `Data.define` and its initializer.
  class Definition
    # @param attribute_names [Array<Symbol>]
    def initialize(attribute_names)
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
  end
end
