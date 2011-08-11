module Databasedotcom
  module Sobject
    # An object naming wrapper, for form_for compatibility
    class ObjectName
      def initialize(name)
        @name = name
      end

      # The singular name of this model.  Returns the full model name, by default.
      def singular
        @name
      end
    end
  end
end