require "sinatra/base"
require "sinatra/json"
require "logger"
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
    File.read(screenshot)
    send_file screenshot, :type => :jpg

  end

  # post "/" do
  #   push = URI.decode_www_form(request.body.read).to_h
  #   LOGGER.info "main: POST #{push}"

  #   fork do
  #     send_snapshot(push["response_url"], push["user_id"])
  #   end

  #   json(
  #     {
  #       response_type: "in_channel",
  #       text: ""
  #     }
  #   )
  # end

  def load_screenshot(downloader)
    playlist_url = downloader.playlist_url
    LOGGER.info "load_screenshot: playlist_url = #{playlist_url}"
  end

  def send_snapshot(response_url, user_id)
    LOGGER.info "send_snapshot: response_url = #{response_url}"
    LOGGER.info "send_snapshot: user_id      = #{user_id}"

    # link = downloader.upload_to_imgur(screenshot)
    # LOGGER.info "send_snapshot: deleting #{screenshot}"
    # File.delete(screenshot)

    # sarcasm = [
    #   "Here is my latest selfie! <@#{user_id}>",
    #   "Ok, <@#{user_id}>, here is your freakin' picture.",
    #   "I see sweaty people",
    #   "Stalk much, <@#{user_id}>?"
    # ]

    # slack_response = {
    #   replace_original: true,
    #   response_type: "in_channel",
    #   text: sarcasm.sample,
    #   attachments: [
    #     {
    #       text: "",
    #       image_url: link
    #     }
    #   ]
    # }

    # HTTP.post(response_url, json: slack_response)
  rescue StandardError => error
    HTTP.post(response_url, json: { response_type: "in_channel", text: "Crap, something went wrong (#{error})"})
  end

end
