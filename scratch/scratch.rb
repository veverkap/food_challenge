


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
