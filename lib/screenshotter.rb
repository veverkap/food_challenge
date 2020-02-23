require "open3"
require "logger"

LOGGER = Logger.new(STDOUT) unless defined? LOGGER

class Screenshotter
  class << self
    include LoggingBase
    def snapshot(playlist_url)
      log "playlist_url = #{playlist_url}"
      output_file = "/tmp/bigtexan/images/output#{Time.now.to_i}.jpg"
      log "output_file = #{output_file}"
      Measurer.measure do
        stdout_str, error_str, status = Open3.capture3(which("ffmpeg"), "-i", playlist_url, "-vframes", "1", "-f", "image2", output_file)
        raise error_str unless status.success?
      end
      output_file
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
end
