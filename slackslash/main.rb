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
  include LoggingBase
  # This is a poor man's healthcheck
  get "/" do
    json("ok")
  end

  # This endpoint snapshots the feed live and then serves the image
  get "/snapshot" do
    screenshot = Screenshotter.snapshot(Downloader.playlist_url)
    send_file screenshot, :type => :jpg
  end

  # This endpoint snapshots the feed live and then serves the image
  get "/tweet" do
    screenshot = Screenshotter.snapshot(Downloader.playlist_url)
    tweet = Tweeter.send_tweet(screenshot)
    File.delete(screenshot)
    json({url: "#{tweet.url}"})
  end

  # This endpoint handles the [Slack slash command](https://api.slack.com/legacy/custom-integrations/slash-commands)
  post "/" do
    # Slack sends this body encoded (param1=one&param2=two) so we use decode_www_form to decode it
    form = URI.decode_www_form(request.body.read).to_h
    log "POST form: #{form}"

    fork do
      screenshot = Slacker.send_snapshot(form["response_url"], form["user_id"], Downloader.playlist_url)
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

  # This endpoint handles incoming [Slack events](https://api.slack.com/events-api)
  post "/rt_events" do
    json = JSON.load(request.body.read)
    return json["challenge"] if json["type"] == "url_verification"

    fork do
      Slacker.process_slack_conversation(json) if json["type"] == "event_callback"
    end

    "OK"
  end
end
