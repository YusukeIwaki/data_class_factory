# frozen_string_literal: true

module DataClass
  # An internal module for providing instance methods for `Data.define`.
  module InstanceMethods
    def members
      self.class.members
    end
  end
end
