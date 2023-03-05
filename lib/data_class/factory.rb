# frozen_string_literal: true

module DataClass
  # An internal class for providing implementation of `Data.define`.
  class Factory
    # @param attribute_names [Array<Symbol>]
    def initialize(attribute_names)
      @definition = Definition.new(attribute_names)
    end

    # @param parent_class [Data]
    # @return [Class<Data>]
    def create(parent_class:, &block)
      attribute_names = @definition.attribute_names

      # defines a subclass of Data.
      Class.new(parent_class) do
        public_class_method :new
        private_class_method :define

        attribute_names.each { |key| define_method(key) { @__data[key] } }

        define_singleton_method(:members) { attribute_names }

        class_eval(&block) unless block.nil?
      end
    end
  end
end
