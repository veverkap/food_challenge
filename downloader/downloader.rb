require "rubygems"
require "bundler/setup"
require "benchmark"
require "fileutils"
require "down/http"
require "aws-sdk-s3"
require "streamio-ffmpeg"
require "logger"
require "json"
require "pp"
require "slack-ruby-client"

Aws.config.update(
  endpoint: ENV["MINIO_ENDPOINT"],
  access_key_id: ENV["MINIO_ACCESS_KEY_ID"],
  secret_access_key: ENV["MINIO_SECRET_ACCESS_KEY"],
  force_path_style: true,
  region: 'us-east-1'
)

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

LOGGER = Logger.new(STDOUT)

class Downloader
  attr_reader :frame_url, :playlist_url, :base_url

  def root_dir
    "/tmp/bigtexan" #NO TRAILING SLASH, PATRICK
  end

  def minio_client
    @minio_client ||= Aws::S3::Client.new
  end

  def slack_client
    @client ||= Slack::Web::Client.new
  end

  def initialize(frame_url = "https://v.angelcam.com/iframe?v=9klzdgn2y4")
    FileUtils.mkdir_p("#{root_dir}/images")
    FileUtils.mkdir_p("#{root_dir}/videos")
    @frame_url = frame_url
  end

  def measure(&block)
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    result = block.call
    finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    LOGGER.info "Completed in #{finish - start} seconds"
    result
  end

  def process
    LOGGER.info "process: Begin"
    measure do
      segments = load_ts_segments()
      LOGGER.info "process: Found segments #{segments}"
      destinations = segments.map do |segment_file|
        destination = download_video(segment_file)
        upload_file_to_minio(destination)
        destination
      end

      destination = destinations.sample
      LOGGER.info "process: sampled and processing #{destination}"

      screenshot = snapshot_video(destination)
      upload_file_to_minio(screenshot)

      json = process_screenshot(screenshot)

      LOGGER.info "process: person_found_in_left_box  = #{json["person_found_in_left_box"]}"
      LOGGER.info "process: person_found_in_right_box = #{json["person_found_in_right_box"]}"
      LOGGER.info "process: person_found_in_right_box = #{json["person_found_in_right_box"]}"
      LOGGER.info "process: person_found_in_rectangle = #{json["person_found_in_rectangle"]}"

      if json["person_found_in_rectangle"]
        slack_client.files_upload(
          channels: '#talk-big-texan',
          as_user: false,
          file: Faraday::UploadIO.new(screenshot, 'image/jpeg'),
          title: 'My Avatar',
          filename: 'avatar.jpg',
          initial_comment: 'I see sweaty people'
        )
      end

      upload_json_to_minio(destination, json)

      destinations.each do |destination|
        LOGGER.info "process: deleting #{destination}"
        File.delete(destination)
      end
      File.delete(screenshot)
    end
    LOGGER.info "process: Completed"
  rescue StandardError => error
    LOGGER.error "process: Whoops, something bad happened #{error}"
  end

  def load_ts_segments
    LOGGER.info "load_ts_segments: Loading"
    html = read_url(frame_url)
    @playlist_url = html.match(/(https?:\/\/.*\.m3u8\?token=.*)'/).captures.first
    LOGGER.info "load_ts_segments: playlist_url = #{playlist_url}"
    @base_url = playlist_url.gsub(playlist_url.split("/")[-1], "")
    LOGGER.info "load_ts_segments: base_ur = #{base_url}"
    item = read_url(playlist_url)
    item.scan(/segment-\d*\.ts/)
  end

  def download_video(filename)
    source = base_url + filename
    LOGGER.info "download_video: source = #{source}"
    destination = "#{root_dir}/videos/#{filename}"
    LOGGER.info "download_video: destination = #{destination}"
    download_url(source, destination) unless File.exist?(destination)
    destination
  end

  def snapshot_video(destination)
    screenshot = "#{root_dir}/images/#{destination.split("/").last.gsub(".ts", ".jpg")}"
    LOGGER.info "snapshot_video: #{screenshot}"
    movie = FFMPEG::Movie.new(destination)
    movie.screenshot(screenshot)
    LOGGER.info "snapshot_video: completed"
    screenshot
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

  def upload_file_to_minio(destination)
    filename = destination.split("/").last
    content_type = "video/MP2T"
    folder = "video"

    if File.extname(destination) == ".jpg"
      content_type = "image/jpeg"
      folder = "images"
    end

    contents = File.read(destination)
    key = "#{Time.now.strftime("%F")}/#{folder}/#{filename}"

    upload_to_minio(key, contents, content_type)
  end

  def upload_json_to_minio(destination, json)
    filename = destination.split("/").last.gsub(".ts", ".json")
    key = "#{Time.now.strftime("%F")}/json/#{filename}"
    upload_to_minio(key, JSON.dump(json), "application/json")
  end

  def upload_to_minio(key, contents, content_type)
    LOGGER.info "upload_to_minio: uploading to #{key} with content_type #{content_type}"
    minio_client.put_object(
      key: key,
      body: contents,
      bucket: ENV["MINIO_BUCKET"],
      content_type: content_type
    )
    LOGGER.info "upload_to_minio: uploaded to #{key} with content_type #{content_type}"
    key
  rescue StandardError => error
    LOGGER.error "upload_to_minio: We had an uploading to minio error - #{error}"
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

  def download_url(source, destination)
    LOGGER.info "download_url: #{source} to #{destination}"
    Down::Http.download(source, destination: destination)
  rescue Down::Error => error
    LOGGER.error "download_url: Error downloading #{source} to #{destination} = #{error}"
  end

  def read_url(source)
    LOGGER.info "read_url: #{source}"
    Down::Http.download(source).read
  rescue Down::Error => error
    LOGGER.error "read_url: Error loading #{source} = #{error}"
  end
end
