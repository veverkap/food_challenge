require "rubygems"
require "bundler/setup"
require "aws-sdk-s3"
require "logger"
require "slack-ruby-client"

LOGGER = Logger.new(STDOUT) unless defined? LOGGER

Aws.config.update(
  endpoint: ENV["MINIO_ENDPOINT"],
  access_key_id: ENV["MINIO_ACCESS_KEY_ID"],
  secret_access_key: ENV["MINIO_SECRET_ACCESS_KEY"],
  force_path_style: true,
  region: 'us-east-1'
)

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

class LoggingBase
  def log(msg)
    caller_method = caller_locations.first.label
    LOGGER.info "#{self.class.to_s} (#{caller_method}): #{msg}"
  end

  def logerr(msg)
    caller_method = caller_locations.first.label
    LOGGER.error "#{self.class.to_s} (#{caller_method}): #{msg}"
  end

  class << self
    def log(msg)
      caller_method = caller_locations.first.label
      LOGGER.info "#{self.to_s} (#{caller_method}): #{msg}"
    end

    def logerr(msg)
      caller_method = caller_locations.first.label
      LOGGER.error "#{self.to_s} (#{caller_method}): #{msg}"
    end
  end
end
