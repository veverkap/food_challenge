require "rubygems"
require "bundler/setup"
require "aws-sdk-s3"
require "logger"
require "slack-ruby-client"
require "rainbow"

LOGGER = Logger.new(STDOUT) unless defined? LOGGER
Rainbow.enabled = false

Aws.config.update(
  endpoint: ENV["MINIO_ENDPOINT"],
  access_key_id: ENV["MINIO_ACCESS_KEY_ID"],
  secret_access_key: ENV["MINIO_SECRET_ACCESS_KEY"],
  force_path_style: true,
  region: 'us-east-1'
)
raise "Missing Minio config" if Aws.config[:endpoint].nil? || Aws.config[:access_key_id].nil? || Aws.config[:secret_access_key].nil?

Slack.configure do |config|
  config.token = ENV["SLACK_API_TOKEN"]
  raise "Missing ENV[SLACK_API_TOKEN]!" unless config.token
end

class LoggingBase
  def slack_client
    LoggingBase.slack_client
  end

  def log(msg)
    caller_method = caller_locations.first.label
    LOGGER.info "#{LoggingBase.colored_class(self.class.to_s)} (#{caller_method}): #{msg}"
  end

  def logerr(msg)
    caller_method = caller_locations.first.label
    LOGGER.error "#{LoggingBase.colored_class(self.class.to_s)} (#{caller_method}): #{msg}"
  end

  class << self
    def slack_client
      @client ||= Slack::Web::Client.new
    end

    def log(msg)
      caller_method = caller_locations.first.label
      LOGGER.info "#{colored_class(self.to_s)} (#{caller_method}): #{msg}"
    end

    def logerr(msg)
      caller_method = caller_locations.first.label
      LOGGER.error "#{colored_class(self.to_s)} (#{caller_method}): #{msg}"
    end

    def colored_class(item)
      case item
      when "Processor"
        Rainbow(item).blue.bright
      when "Downloader"
        Rainbow(item).yellow.bright
      when "Uploader"
        Rainbow(item).gray.bright
      else
        Rainbow(item)
      end
    end
  end
end
