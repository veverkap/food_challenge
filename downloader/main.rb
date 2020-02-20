require "sinatra"
require "sinatra/json"
require "sinatra/reloader" if development?
require "./downloader"
require "logger"
require "uri"
require "pp"
require "http"

def send_snapshot(response_url, user_id)
  downloader = Downloader.new
  segment_file = downloader.load_ts_segments().last
  destination = downloader.download_video(segment_file)
  screenshot = downloader.snapshot_video(destination)
  link = downloader.upload_to_imgur(screenshot)
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
