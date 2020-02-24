require "rubygems"
require "bundler/setup"
require "http"
require "json"
require "aws-sdk-s3"

class Uploader
  class << self
    include LoggingBase
    # Uploads the screenshot to imgur
    #
    # @param screenshot [String] URI to screenshot
    # @return [String] URL to imgur link
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

    def get_minio_external_link(key)
      signer = Aws::S3::Presigner.new(client: minio_client)
      signer.presigned_url(:get_object, bucket: ENV["MINIO_BUCKET"], key: key)
    end

    def process_screenshot(screenshot)
      LOGGER.info "process_screenshot: uploading #{screenshot}"
      response = HTTP.post("http://127.0.0.1:8000/detect", :form => {
        :image   => HTTP::FormData::File.new(screenshot)
      })
      result = JSON.load(response.body)
      LOGGER.info "process_screenshot: result = #{result}"
      result
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

      def upload_json_to_minio(destination, json)
        filename = destination.split("/").last.gsub(".ts", ".json")
        key = "#{Time.now.strftime("%F")}/json/#{filename}"
        upload_to_minio(key, JSON.dump(json), "application/json")
      end

      def minio_client
        @minio_client ||= Aws::S3::Client.new
      end
  end
end
