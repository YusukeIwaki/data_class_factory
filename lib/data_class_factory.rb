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
  def backport?
    Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3.2.0')
  end

  # rubocop:disable Metrics/MethodLength
  def define_factory_class
    Class.new do
      define_singleton_method(:define) do |*attribute_names, &block|
        factory = DataClass::Factory.new(attribute_names)
        factory.create(parent_class: self, &block)
      end
      private_class_method :new

      define_method(:initialize) do |**kwargs|
        definition = DataClass::Definition.new(self.class.members)
        definition.validate(kwargs)

        @data = {}
        kwargs.each do |key, value|
          @data[key] = value
        end
        @data.freeze
        freeze
      end

      define_method(:initialize_copy) do |other|
        @data = other.instance_variable_get(:@data).dup
        @data.freeze
        freeze
      end

      include DataClass::InstanceMethods
    end
  end
  # rubocop:enable Metrics/MethodLength

  module_function :backport?, :define_factory_class
end

require_relative './data'
