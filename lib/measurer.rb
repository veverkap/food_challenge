class Measurer < LoggingBase
  class << self
    def measure(&block)
      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      result = block.call
      finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      log "Completed in #{finish - start} seconds"
      result
    end
  end
end
