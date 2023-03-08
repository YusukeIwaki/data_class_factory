# frozen_string_literal: true

require 'data_class_factory/version'
require 'data_class/definer'
require 'data_class/definition'
require 'data_class/instance_methods'

# Defining a factory class.
# `Data = DataClassFactory.define_factory_class` will define a factory class like this.
#
#    class Data
#      # @param attribute_names [Array<Symbol>]
#      # @return [Class<Data>]
#      def self.define(*attribute_names, &block)
#        definition = DataClass::Definition.new(attribute_names)
#        definer = DataClass::Definer.new(definition)
#        definer.define_class(parent_class: self, &block)
#      end
#      ...
#    end
#
module DataClassFactory
  def backport?
    Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3.2.0')
  end

  def define_factory_class
    Class.new do
      define_singleton_method(:define) do |*attribute_names, &block|
        definition = DataClass::Definition.new(attribute_names)
        definer = DataClass::Definer.new(definition)
        definer.define_class(parent_class: self, &block)
      end
      private_class_method :new

      include DataClass::InstanceMethods
    end
  end
  module_function :backport?, :define_factory_class
end

require_relative './data'
