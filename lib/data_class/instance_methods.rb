# frozen_string_literal: true

module DataClass
  module InstanceMethods
    def members
      self.class.members
    end
  end
end
