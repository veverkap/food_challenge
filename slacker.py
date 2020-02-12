import slack
import twitter


class Slacker:
    def postToTwitter(image, message='I see people'):
        api = twitter.Api(consumer_key=os.environ['TWITTER_CONSUMER_KEY'],
                          consumer_secret=os.environ['TWITTER_CONSUMER_SECRET'],
                          access_token_key=os.environ['TWITTER_ACCESS_TOKEN_KEY'],
                          access_token_secret=os.environ['TWITTER_ACCESS_TOKEN_SECRET'])
        status = api.PostUpdate(status=message,
                                media=image)

    def postToSlack(image):
        client = slack.WebClient(
            token=os.environ['SLACK_API_TOKEN'])
        response = client.files_upload(
            channels='#talk-big-texan',
            initial_comment='I see people',
            title=image,
            file=image)
