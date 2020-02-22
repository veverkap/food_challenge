require "sinatra/base"
require "sinatra/json"
require "logger"
require "../lib/logging_base"
Dir.glob(File.join("..", "lib", "**", "*.rb"), &method(:require))
# require "uri"
# require "pp"
# require "http"

LOGGER = Logger.new(STDOUT) unless defined? LOGGER

class MainApp < Sinatra::Base
  def downloader
    @downloader = Downloader.new
  end

  def uploader
    @uploader = Uploader.new
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
      Slacker.send_snapshot(form["response_url"], form["user_id"], downloader)
    end

    json(
      {
        response_type: "in_channel",
        text: ""
      }
    )
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
