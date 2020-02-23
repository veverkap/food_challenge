require "pp"
class Processor < LoggingBase
  class << self
    def process
      Rainbow.enabled = true
        # get snapshot

        # post to python app

        # procees results
    end

    def downloader
      @downloader ||= Downloader.new
    end

  end
end
