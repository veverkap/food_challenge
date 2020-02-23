require "rubygems"
require "bundler/setup"
require "twitter"

class Tweeter < LoggingBase
  class << self
    def send_tweet(screenshot)
      log "sending screenshot"
      sarcasm = [
        "Here is my latest selfie!",
        "I see sweaty people",
        "MEATSWEATS"
      ]
      tweet = twitter_client.update_with_media(sarcasm.sample, screenshot)
      log "completed with #{tweet}"
    end

    def twitter_client
      @client ||= Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
        config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
        config.access_token        = ENV["TWITTER_ACCESS_TOKEN_KEY"]
        config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
      end
    end
  end
end
