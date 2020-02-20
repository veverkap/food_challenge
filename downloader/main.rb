require "sinatra"
require "sinatra/json"
require "sinatra/reloader" if development?
require "./downloader"
require "logger"

LOGGER = Logger.new(STDOUT)

get "/" do
  "/"
end

post "/" do
  downloader = Downloader.new
  segment_file = downloader.load_ts_segments().last
  destination = downloader.download_video(segment_file)
  screenshot = downloader.snapshot_video(destination)
  puts downloader.upload_file_to_minio(screenshot)
  json(
    {
      response_type: "in_channel",
      attachments: [
        {
          text: "",
          image_url: "https://minioext.veverka.net/meatsweats/2020-02-19/images/segment-151848.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=meatsweats%2F20200220%2F%2Fs3%2Faws4_request&X-Amz-Date=20200220T020109Z&X-Amz-Expires=432000&X-Amz-SignedHeaders=host&X-Amz-Signature=7fe631f3bac2bd38b33312e3d58ee1d250add09aff9d1ce7413ab563d3662970"
        }
      ]
    })

end
