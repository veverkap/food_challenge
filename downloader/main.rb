require "sinatra"
require "sinatra/json"
require "sinatra/reloader" if development?
require "./downloader"
require "open3"
require "logger"
require "uri"
require "pp"
require "http"

def load_screenshot(downloader)
  playlist_url = downloader.playlist_url
  LOGGER.info "load_screenshot: playlist_url = #{playlist_url}"
  output = "/tmp/bigtexan/images/output#{Time.now.to_i}.jpg"
  LOGGER.info "load_screenshot: snapshotting to #{output}"
  downloader.measure do
    stdout_str, error_str, status = Open3.capture3("/usr/local/bin/ffmpeg", "-i", playlist_url, "-vframes", "1", "-f", "image2", output)
    raise error_str unless status.success?
  end
  output
end

def send_snapshot(response_url, user_id)
  LOGGER.info "send_snapshot: response_url = #{response_url}"
  LOGGER.info "send_snapshot: user_id      = #{user_id}"
  downloader = Downloader.new
  screenshot = load_screenshot(downloader)
  link = downloader.upload_to_imgur(screenshot)
  LOGGER.info "send_snapshot: deleting #{screenshot}"
  File.delete(screenshot)

  sarcasm = [
    "Here is my latest selfie! <@#{user_id}>",
    "Ok, <@#{user_id}>, here is your freakin' picture.",
    "I see sweaty people",
    "Stalk much, <@#{user_id}>?"
  ]

  slack_response = {
    replace_original: true,
    response_type: "in_channel",
    text: sarcasm.sample,
    attachments: [
      {
        text: "",
        image_url: link
      }
    ]
  }

  HTTP.post(response_url, json: slack_response)
rescue StandardError => error
  HTTP.post(response_url, json: { response_type: "in_channel", text: "Crap, something went wrong (#{error})"})
end

get "/" do
  "/"
end

post "/" do
  push = URI.decode_www_form(request.body.read).to_h
  LOGGER.info "main: POST #{push}"

  fork do
    send_snapshot(push["response_url"], push["user_id"])
  end

  json(
    {
      response_type: "in_channel",
      text: ""
    }
  )
end
