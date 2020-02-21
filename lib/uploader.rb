require "rubygems"
require "bundler/setup"
require "http"
require "json"

class Uploader < LoggingBase
  class << self
    IMGUR_URL = "https://api.imgur.com/3/upload"
    def upload_to_imgur(screenshot)
      log "uploading #{screenshot}"


      response = HTTP.auth("Client-ID #{ENV["IMGUR_CLIENT_ID"]}")
                     .post(IMGUR_URL,
                        form: {
                          image: HTTP::FormData::File.new(screenshot)
                        })

      link = JSON.load(response.to_s)["data"]["link"]
      log "uploaded to #{link}"
      link
    end
  end
end
