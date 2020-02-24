require "rubygems"
require "bundler/setup"
require "benchmark"
require "fileutils"
require "down/http"
require "aws-sdk-s3"
require "logger"
require "json"
require "pp"
require "slack-ruby-client"

class Downloader
  class << self
    FRAME_URL = "https://v.angelcam.com/iframe?v=9klzdgn2y4".freeze
    ROOT_DIR  = "/tmp/bigtexan".freeze #NO TRAILING SLASH, PATRICK

    include LoggingBase

    # Loads the m3u8 playlist URL from the [FRAME_URL]
    #
    # @return [String] the playlist url
    def playlist_url
      log "finding playlist_url"
      html = read_url(FRAME_URL)
      html.match(/(https?:\/\/.*\.m3u8\?token=.*)'/).captures.first
    end

    # Parses the segment.ts files from  the m3u8 playlist URL (see #playlist_url)
    #
    # @return [Array<String>] segment.ts files from the m3u8 file
    def load_ts_segments
      current_playlist_url = playlist_url
      @base_url = current_playlist_url.gsub(current_playlist_url.split("/")[-1], "")
      log "base_url = #{base_url}"
      item = read_url(current_playlist_url)
      item.scan(/segment-\d*\.ts/)
    end

    # Downloads video file to appropriately renamed file in [ROOT_DIR]
    #
    # @param filename [String] filename to download
    # @return [String] location of downloaded file
    def download_video(filename)
      source = base_url + filename
      log "source = #{source}"
      destination = "#{ROOT_DIR}/videos/#{filename}"
      log "destination = #{destination}"
      download_url(source, destination) unless File.exist?(destination)
      destination
    end

    # Downloads and reads stream from source
    #
    # @param source [String] url to read
    # @return [String] body of url
    def read_url(source)
      log "source = #{source}"
      Down::Http.download(source).read
    rescue Down::Error => error
      logerr "Error loading #{source} = #{error}"
    end

    # Downloads source to destination
    #
    # @param source [String] url to download
    # @param destination [String] location to download file to
    # @return [nil]
    def download_url(source, destination)
      log "#{source} to #{destination}"
      Down::Http.download(source, destination: destination)
    rescue Down::Error => error
      logerr "Error downloading #{source} to #{destination} = #{error}"
    end
  end
end
