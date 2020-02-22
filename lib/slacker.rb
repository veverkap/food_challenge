require "http"

class Slacker < LoggingBase
  class << self
    def send_snapshot(response_url, user_id, downloader)
      log "response_url = #{response_url}"
      log "user_id      = #{user_id}"

      screenshot = Screenshotter.snapshot(downloader.playlist_url)
      link = Uploader.upload_to_imgur(screenshot)
      log "link = #{link}"
      log "deleting #{screenshot}"
      File.delete(screenshot)

      sarcasm = [
        "Here is my latest selfie! <@#{user_id}>",
        "Ok, <@#{user_id}>, here is your freakin' picture.",
        "I see sweaty people",
        "Stalk much, <@#{user_id}>?"
      ]

      slack_response = {
        replace_original: true,
        response_type: "in_channel",
        text: sarcasm.sample,
        attachments: [
          {
            text: "",
            image_url: link
          }
        ]
      }

      log "slack_response = #{slack_response}"
      http_response = HTTP.post(response_url, json: slack_response)
      log "http_response = #{http_response}"
    rescue StandardError => error
      logerr "Error posting to Slack: #{error}"
      HTTP.post(response_url, json: { response_type: "in_channel", text: "Crap, something went wrong (#{error})"})
    end
  end
end
