require 'fastlane/action'
require_relative '../helper/hy_pgyer_helper'
require 'faraday'
require 'faraday_middleware'

module Fastlane
  module Actions
    class HyPgyerAction < Action
      $downloadUrl = ""
      $downloadCodeQrUrl = ""
      def self.run(params)
        api_host = "http://qiniu-storage.pgyer.com/apiv1/app/upload"
        api_key = params[:api_key]
        user_key = params[:user_key]

        build_file = [
          params[:ipa],
          params[:apk]
        ].detect { |e| !e.to_s.empty? }

        if build_file.nil?
          UI.user_error!("没有build file文件参数")
        end

        UI.message "build_file: #{build_file}"

        password = params[:password]
        if password.nil?
          password = ""
        end

        update_description = params[:update_description]
        if update_description.nil?
          update_description = ""
        end

        install_type = params[:install_type]
        if install_type.nil?
          install_type = "1"
        end

        # start upload
        conn_options = {
          request: {
            timeout:       1000,
            open_timeout:  300
          }
        }

        pgyer_client = Faraday.new(nil, conn_options) do |c|
          c.request :multipart
          c.request :url_encoded
          c.response :json, content_type: /\bjson$/
          c.adapter :net_http
        end

        params = {
            '_api_key' => api_key,
            'uKey' => user_key,
            'password' => password,
            'updateDescription' => update_description,
            'installType' => install_type,
            'file' => Faraday::UploadIO.new(build_file, 'application/octet-stream')
        }

        UI.message "开始上传 #{build_file} 到蒲公英..."

        response = pgyer_client.post api_host, params
        info = response.body
        UI.success "返回结果----------#{info}"
        if info['code'] != 0
          UI.user_error!("PGYER Plugin 错误: #{info['message']}")
        end
          @downloadUrl = "https://www.pgyer.com/#{info['data']['appShortcutUrl']}"
          @downloadCodeQrUrl = info['data']['appQRCodeURL']
          UI.success "上传成功下载地址: https://www.pgyer.com/#{info['data']['appShortcutUrl']}"
          return [@downloadUrl, @downloadCodeQrUrl]
      end

      def self.description
        "蒲公英上传插件"
      end

      def self.authors
        ["astrye"]
      end

      def self.return_value
         "返回数组类型：【第一个元素为蒲公英下载URL，第二个元素为蒲公英下载的二维码图片地址URL】"
      end

      def self.details
        "蒲公英上传打包插件，返回上传后的下载地址，方便对地址进行发送到相应QQ或微信群内------"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :api_key,
                                  env_name: "PGYER_API_KEY",
                               description: "api_key in your pgyer account",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :user_key,
                                  env_name: "PGYER_USER_KEY",
                               description: "user_key in your pgyer account",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :apk,
                                       env_name: "PGYER_APK",
                                       description: "Path to your APK file",
                                       default_value: Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH],
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find apk file at path '#{value}'") unless File.exist?(value)
                                       end,
                                       conflicting_options: [:ipa],
                                       conflict_block: proc do |value|
                                         UI.user_error!("You can't use 'apk' and '#{value.key}' options in one run")
                                       end),
          FastlaneCore::ConfigItem.new(key: :ipa,
                                       env_name: "PGYER_IPA",
                                       description: "Path to your IPA file. Optional if you use the _gym_ or _xcodebuild_ action. For Mac zip the .app. For Android provide path to .apk file",
                                       default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find ipa file at path '#{value}'") unless File.exist?(value)
                                       end,
                                       conflicting_options: [:apk],
                                       conflict_block: proc do |value|
                                         UI.user_error!("You can't use 'ipa' and '#{value.key}' options in one run")
                                       end),
          FastlaneCore::ConfigItem.new(key: :password,
                                  env_name: "PGYER_PASSWORD",
                               description: "set password to protect app",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :update_description,
                                  env_name: "PGYER_UPDATE_DESCRIPTION",
                               description: "set update description for app",
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :install_type,
                                  env_name: "PGYER_INSTALL_TYPE",
                               description: "set install type for app (1=public, 2=password, 3=invite). Please set as a string",
                                  optional: true,
                                      type: String)
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end

