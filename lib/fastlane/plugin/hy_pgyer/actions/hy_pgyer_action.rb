require 'fastlane/action'
require_relative '../helper/hy_pgyer_helper'

module Fastlane
  module Actions
    class HyPgyerAction < Action
      def self.run(params)
        UI.message("The hy_pgyer plugin is working!")
      end

      def self.description
        "蒲公英上传插件"
      end

      def self.authors
        ["astrye"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "iOS蒲公英上传打包插件"
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "HY_PGYER_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
