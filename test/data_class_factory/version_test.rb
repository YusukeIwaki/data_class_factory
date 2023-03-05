# frozen_string_literal: true

require 'test_helper'

module DataClassFactory
  class VersionTest < Minitest::Test
    def test_version_present
      version = Gem::Version.new(DataClassFactory::VERSION)
      assert version >= Gem::Version.new('0.0.1')
    end
  end
end
