# frozen_string_literal: true

module DataClass
  class Factory
    def initialize(attribute_names)
      @attribute_names = attribute_names
    end

    def create(parent_class:, &block)
      attribute_names = @attribute_names

      Class.new(parent_class) do
        attr_reader(*attribute_names)

        define_singleton_method(:members) { attribute_names }

        define_method(:initialize) do |**kwargs|
          if attribute_names - kwargs.keys != []
            raise ArgumentError, "missing keyword: #{(attribute_names - kwargs.keys).join(', ')}"
          end

          if kwargs.keys - attribute_names != []
            raise ArgumentError, "unknown keyword: #{(kwargs.keys - attribute_names).join(', ')}"
          end

          kwargs.each do |key, value|
            instance_variable_set("@#{key}".to_sym, value)
          end
        end

        unless block.nil?
          class_eval(&block)
        end
      end
    end
  end
end
