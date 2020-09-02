require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class HyPgyerHelper
      # class methods that you define here become available in your action
      # as `Helper::HyPgyerHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the hy_pgyer plugin helper!")
      end
    end
  end
end
