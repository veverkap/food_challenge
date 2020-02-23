require "rubygems"
require "bundler/setup"
require "sinatra/base"
require "sinatra/json"
require "logger"
require "json"
require "../lib/logging_base"
Dir.glob(File.join("..", "lib", "**", "*.rb"), &method(:require))

LOGGER = Logger.new(STDOUT) unless defined? LOGGER

class MainApp < Sinatra::Base
  def downloader
    @downloader ||= Downloader.new
  end

  get "/" do
    json("ok")
  end

  get "/snapshot" do
    screenshot = Screenshotter.snapshot(downloader.playlist_url)
    send_file screenshot, :type => :jpg
  end

  post "/" do
    form = URI.decode_www_form(request.body.read).to_h
    log "POST form: #{form}"

    fork do
      screenshot = Slacker.send_snapshot(form["response_url"], form["user_id"], downloader.playlist_url)
      Tweeter.send_tweet(screenshot)
      File.delete(screenshot)
    end

    json(
      {
        response_type: "in_channel",
        text: ""
      }
    )
  end

  post "/rt_events" do
    json = JSON.load(request.body.read)
    return json["challenge"] if json["type"] == "url_verification"

    fork do
      Slacker.process_slack_conversation(json) if json["type"] == "event_callback"
    end

    "OK"
  end

  def log(msg)
    caller_method = caller_locations.first.label
    LOGGER.info "#{self.class.to_s} (#{caller_method}): #{msg}"
  end

  def logerr(msg)
    caller_method = caller_locations.first.label
    LOGGER.error "#{self.class.to_s} (#{caller_method}): #{msg}"
  end
end
