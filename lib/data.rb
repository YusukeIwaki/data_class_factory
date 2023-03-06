# frozen_string_literal: true

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('3.0.0')
  warn 'Removing original `Data` class', uplevel: 3
  Object.send(:remove_const, :Data)
end
Data = DataClassFactory.define_factory_class if DataClassFactory.backport?
