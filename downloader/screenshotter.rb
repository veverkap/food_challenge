require "sinatra"
require "sinatra/base"
require "sinatra/json"
require "sinatra/reloader"# if development?
require "./downloader"
require "./uploader"
require "open3"
require "logger"
require "uri"
require "pp"
require "http"



class Screenshotter
  attr_reader :playlist_url

  def initialize(playlist_url)
    @playlist_url = playlist_url
  end

  def snapshot
    output_file = "/tmp/bigtexan/images/output#{Time.now.to_i}.jpg"
    measure do
      stdout_str, error_str, status = Open3.capture3(which("ffmpeg"), "-i", playlist_url, "-vframes", "1", "-f", "image2", output)
      raise error_str unless status.success?
    end
    output_file
  end

  def measure(&block)
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    result = block.call
    finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    LOGGER.info "Completed in #{finish - start} seconds"
    result
  end

  def which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each { |ext|
        exe = File.join(path, "#{cmd}#{ext}")
        return exe if File.executable? exe
      }
    end
    raise Errno::ENOENT, "the #{cmd} binary could not be found in #{ENV['PATH']}"
  end
end
