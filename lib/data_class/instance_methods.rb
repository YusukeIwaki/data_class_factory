# frozen_string_literal: true

module DataClass
  # An internal module for providing instance methods for `Data.define`.
  module InstanceMethods
    def deconstruct
      @data.values
    end

    # @param array_of_names_or_nil [Array<Symbol>, nil]
    def deconstruct_keys(array_of_names_or_nil)
      return to_h if array_of_names_or_nil.nil?

      unless array_of_names_or_nil.is_a?(Enumerable)
        raise TypeError, "wrong argument type #{array_of_names_or_nil.class} (expected Array or nil)"
      end

      array_of_names_or_nil.each_with_object({}) do |key, h|
        h[key] = @data[key] if @data[key]
      end
    end

    # @return [Boolean]
    def eql?(other)
      hash_for_comparation.eql?(other.hash_for_comparation)
    end

    # @return [Integer]
    def hash
      hash_for_comparation.hash
    end

    # @return [String]
    def inspect
      if self.class.name
        "#<data #{self.class.name} #{inspect_members}>"
      else
        "#<data #{inspect_members}>"
      end
    end

    def members
      self.class.members
    end

    def to_h(&block)
      @data.each_with_object({}) do |key_and_value, h|
        key, value = block ? block.call(*key_and_value) : key_and_value
        h[key] = value
      end.to_h
    end

    def to_s
      inspect
    end

    # @return [Boolean]
    def ==(other)
      hash_for_comparation == other.hash_for_comparation
    end

    protected

    def hash_for_comparation
      @hash_for_comparation ||= { type: self.class, data: @data }
    end

    private

    # @return [String]
    def inspect_members
      @data.map do |key, value|
        if key =~ /\A[a-zA-Z_][a-zA-Z0-9_]*\z/
          "#{key}=#{value.inspect}"
        else
          "#{key.inspect}=#{value.inspect}"
        end
      end.join(', ')
    end
  end
end
