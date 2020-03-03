require "http"
require "pp"

class Slacker
  class << self
    include LoggingBase

    KEYWORD = ENV["SLACK_KEYWORD"].freeze
    # Parses Slack conversation and acts upon it.
    #
    # @param json [Hash] conversation in Hash format [API Details](https://api.slack.com/events-api)
    def process_slack_conversation(json)
      event = json["event"]
      return if event.fetch("subtype", nil) == "bot_message"

      text = event.fetch("text", "")
      log "text = #{text}"
      channel = event.fetch("channel", "#talk-big-texan-debug")
      log "channel = #{channel}"
      thread_ts = event.fetch("ts", "")
      log "thread_ts = #{thread_ts}"

      if text.downcase =~ Regexp.new(KEYWORD)
        screenshot = Screenshotter.snapshot(Downloader.playlist_url)
        link = Uploader.upload_to_imgur(screenshot)
        log "link = #{link}"
        log "deleting #{screenshot}"

        slack_client.chat_postMessage(channel: channel, text: "Here's what I got", thread_ts: thread_ts, attachments: [
          {
            text: "",
            image_url: link
          }
        ])

        Tweeter.send_tweet(screenshot)
        File.delete(screenshot)
      end
    rescue StandardError => error
      puts error.backtrace.inspect
      pp error
    end

    # Send snapshot from playlist to response_url with a funny comment to user_id
    #
    # @param response_url [String] Slack provided URL to POST to
    # @param user_id [String] User that called the Slack slash command
    # @param playlist_url [String] url of the m3u8 file
    def send_snapshot(response_url, user_id, playlist_url)
      log "response_url = #{response_url}"
      log "user_id      = #{user_id}"

      screenshot = Screenshotter.snapshot(playlist_url)
      link = Uploader.upload_to_imgur(screenshot)
      log "link = #{link}"
      log "deleting #{screenshot}"


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
      screenshot
    rescue StandardError => error
      logerr "Error posting to Slack: #{error}"
      HTTP.post(response_url, json: { response_type: "in_channel", text: "Crap, something went wrong (#{error})"})
    end
  end
end
