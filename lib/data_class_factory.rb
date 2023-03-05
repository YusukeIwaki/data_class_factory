# frozen_string_literal: true

require 'data_class_factory/version'
require 'data_class/definition'
require 'data_class/factory'
require 'data_class/instance_methods'

# Defining a factory class.
# `Data = DataClassFactory.define_factory_class` will define a factory class like this.
#
#    class Data
#      # @param attribute_names [Array<Symbol>]
#      # @return [Class<Data>]
#      def self.define(*attribute_names, &block)
#        factory = DataClass::Factory.new(attribute_names)
#        factory.create(parent_class: self, &block)
#      end
#      ...
#    end
#
module DataClassFactory
  # rubocop:disable Metrics/MethodLength
  def define_factory_class
    Class.new do
      define_singleton_method(:define) do |*attribute_names, &block|
        factory = DataClass::Factory.new(attribute_names)
        factory.create(parent_class: self, &block)
      end

      define_method(:initialize) do |**kwargs|
        definition = DataClass::Definition.new(self.class.members)
        definition.validate(kwargs)

        kwargs.each do |key, value|
          instance_variable_set("@#{key}".to_sym, value)
        end
      end

      include DataClass::InstanceMethods
    end
  end
  # rubocop:enable Metrics/MethodLength

  module_function :define_factory_class
end

require_relative './data'
