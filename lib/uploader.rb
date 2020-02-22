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
  end
end
