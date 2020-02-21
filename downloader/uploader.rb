require "rubygems"
require "bundler/setup"
require "aws-sdk-s3"
require "logger"

Aws.config.update(
  endpoint: ENV["MINIO_ENDPOINT"],
  access_key_id: ENV["MINIO_ACCESS_KEY_ID"],
  secret_access_key: ENV["MINIO_SECRET_ACCESS_KEY"],
  force_path_style: true,
  region: 'us-east-1'
)

LOGGER = Logger.new(STDOUT)

class Uploader
  def initialize
  end

  def minio_client
    @minio_client ||= Aws::S3::Client.new
  end

  def upload_to_imgur(screenshot)
    LOGGER.info "upload_to_imgur: uploading #{screenshot}"
    url = "https://api.imgur.com/3/upload"

    response = HTTP.auth("Client-ID #{ENV["IMGUR_CLIENT_ID"]}").post("https://api.imgur.com/3/upload", :form => {
      :image   => HTTP::FormData::File.new(screenshot)
    })
    link = JSON.load(response.to_s)["data"]["link"]
    LOGGER.info "upload_to_imgur: uploaded to #{link}"
    link
  end
end
