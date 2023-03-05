# frozen_string_literal: true

require 'data_class_factory/version'
require 'data_class/factory'
require 'data_class/instance_methods'

module DataClassFactory
  # Defining a factory class.
  # `Data = DataClassFactory.define_factory_class` will define a factory class like this.
  #
  #    class Data
  #      # @param attribute_names [Array<Symbol>]
  #      # @return [Class<Data>]
  #      def self.define(*attribute_names, &block)
  #        DataClass::Factory.new(attribute_names).create(parent_class: self, &block)
  #      end
  #      include DataClass::InstanceMethods
  #    end
  #
  def define_factory_class
    Class.new do
      define_singleton_method(:define) do |*attribute_names, &block|
        factory = DataClass::Factory.new(attribute_names)
        factory.create(parent_class: self, &block)
      end
      include DataClass::InstanceMethods
    end
  end

  module_function :define_factory_class
end

require_relative './data'
