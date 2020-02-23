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

class Downloader < LoggingBase
  attr_reader :frame_url, :base_url

  def initialize(frame_url = "https://v.angelcam.com/iframe?v=9klzdgn2y4")
    log "making tmp directories"
    FileUtils.mkdir_p("#{root_dir}/images")
    FileUtils.mkdir_p("#{root_dir}/videos")
    @frame_url = frame_url
  end

  def playlist_url
    log "finding playlist_url"
    html = read_url(frame_url)
    html.match(/(https?:\/\/.*\.m3u8\?token=.*)'/).captures.first
  end

  def load_ts_segments
    current_playlist_url = playlist_url
    @base_url = current_playlist_url.gsub(current_playlist_url.split("/")[-1], "")
    log "base_url = #{base_url}"
    item = read_url(current_playlist_url)
    item.scan(/segment-\d*\.ts/)
  end

  def download_video(filename)
    source = base_url + filename
    log "source = #{source}"
    destination = "#{root_dir}/videos/#{filename}"
    log "destination = #{destination}"
    download_url(source, destination) unless File.exist?(destination)
    destination
  end

  private

  def root_dir
    "/tmp/bigtexan" #NO TRAILING SLASH, PATRICK
  end

  def read_url(source)
    log "source = #{source}"
    Down::Http.download(source).read
  rescue Down::Error => error
    logerr "Error loading #{source} = #{error}"
  end

  def download_url(source, destination)
    log "#{source} to #{destination}"
    Down::Http.download(source, destination: destination)
  rescue Down::Error => error
    logerr "Error downloading #{source} to #{destination} = #{error}"
  end




  # def measure(&block)
  #   start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  #   result = block.call
  #   finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  #   LOGGER.info "Completed in #{finish - start} seconds"
  #   result
  # end

  # def process
  #   LOGGER.info "process: Begin"
  #   measure do
  #     segments = load_ts_segments()
  #     LOGGER.info "process: Found segments #{segments}"
  #     destinations = segments.map do |segment_file|
  #       destination = download_video(segment_file)
  #       upload_file_to_minio(destination)
  #       destination
  #     end

  #     destination = destinations.sample
  #     LOGGER.info "process: sampled and processing #{destination}"

  #     screenshot = snapshot_video(destination)
  #     upload_file_to_minio(screenshot)

  #     json = process_screenshot(screenshot)

  #     LOGGER.info "process: person_found_in_left_box  = #{json["person_found_in_left_box"]}"
  #     LOGGER.info "process: person_found_in_right_box = #{json["person_found_in_right_box"]}"
  #     LOGGER.info "process: person_found_in_right_box = #{json["person_found_in_right_box"]}"
  #     LOGGER.info "process: person_found_in_rectangle = #{json["person_found_in_rectangle"]}"

  #     if json["person_found_in_rectangle"]
  #       slack_client.files_upload(
  #         channels: '#talk-big-texan',
  #         as_user: false,
  #         file: Faraday::UploadIO.new(screenshot, 'image/jpeg'),
  #         title: 'My Avatar',
  #         filename: 'avatar.jpg',
  #         initial_comment: 'I see sweaty people'
  #       )
  #     end

  #     upload_json_to_minio(destination, json)

  #     destinations.each do |destination|
  #       LOGGER.info "process: deleting #{destination}"
  #       File.delete(destination)
  #     end
  #     File.delete(screenshot)
  #   end
  #   LOGGER.info "process: Completed"
  # rescue StandardError => error
  #   LOGGER.error "process: Whoops, something bad happened #{error}"
  # end





  # def snapshot_video(destination)
  #   screenshot = "#{root_dir}/images/#{destination.split("/").last.gsub(".ts", ".jpg")}"
  #   LOGGER.info "snapshot_video: #{screenshot}"
  #   movie = FFMPEG::Movie.new(destination)
  #   movie.screenshot(screenshot)
  #   LOGGER.info "snapshot_video: completed"
  #   screenshot
  # end



  # def upload_json_to_minio(destination, json)
  #   filename = destination.split("/").last.gsub(".ts", ".json")
  #   key = "#{Time.now.strftime("%F")}/json/#{filename}"
  #   upload_to_minio(key, JSON.dump(json), "application/json")
  # end



  # def get_minio_external_link(key)
  #   signer = Aws::S3::Presigner.new(client: minio_client)
  #   signer.presigned_url(:get_object, bucket: ENV["MINIO_BUCKET"], key: key)
  # end

  # def process_screenshot(screenshot)
  #   LOGGER.info "process_screenshot: uploading #{screenshot}"
  #   response = HTTP.post("http://127.0.0.1:8000/detect", :form => {
  #     :image   => HTTP::FormData::File.new(screenshot)
  #   })
  #   result = JSON.load(response.body)
  #   LOGGER.info "process_screenshot: result = #{result}"
  #   result
  # end




end
