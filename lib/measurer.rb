class Measurer
  class << self
    include LoggingBase
    # Measures how long the execution of the block takes
    #
    # @param block [Block] some block
    # @return [Object] output of block.call
    def measure(&block)
      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      result = block.call
      finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      log "Completed in #{finish - start} seconds"
      result
    end
  end
end
