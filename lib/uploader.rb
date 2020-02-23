require "rubygems"
require "bundler/setup"
require "http"
require "json"

class Uploader < LoggingBase
  class << self
    def upload_to_imgur(screenshot)
      log "uploading #{screenshot}"

      Measurer.measure do
        response = HTTP.auth("Client-ID #{ENV["IMGUR_CLIENT_ID"]}")
                      .post(ENV["IMGUR_API_URL"],
                          form: {
                            image: HTTP::FormData::File.new(screenshot)
                          })
        log "response: #{response.to_s}"
        link = JSON.load(response.to_s)["data"]["link"]
        log "uploaded to #{link}"
        link
      end
    end

    def upload_file_to_minio(destination)
      filename = destination.split("/").last
      content_type = "video/MP2T"
      folder = "video"

      if File.extname(destination) == ".jpg"
        content_type = "image/jpeg"
        folder = "images"
      end

      log "filename = #{filename}"
      contents = File.read(destination)
      key = "#{Time.now.strftime("%F")}/#{folder}/#{filename}"

      upload_to_minio(key, contents, content_type)
    end

    private
      def upload_to_minio(key, contents, content_type)
        log "uploading to #{key} with content_type #{content_type}"
        minio_client.put_object(
          key: key,
          body: contents,
          bucket: ENV["MINIO_BUCKET"],
          content_type: content_type
        )
        log "uploaded to #{key} with content_type #{content_type}"
        key
      rescue StandardError => error
        logerr "We had an error - #{error}"
      end

      def minio_client
        @minio_client ||= Aws::S3::Client.new
      end
  end
end
