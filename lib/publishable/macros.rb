module Publishable
  module Macros

    def publishable(options = {})
      # Work in singleton class
      # Add a read-only class variable to all classes that call `publishable`
      class << self
        attr_reader :publishable_options
      end
      @publishable_options = options

      # include Publishable::ClassMethods
      # include Publishable::Methods
      extend Publishable::Schema
    end

  end
end
