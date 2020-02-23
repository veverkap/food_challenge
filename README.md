So, you want to see MeatSweats?

![gif](https://media.giphy.com/media/3oxHQG9Ks6OtIIMX8A/giphy.gif)

There are three main components to this "app".  Each application has a README of its own that discusses setup and running the apps (or it will soon)

## Downloader (WIP)

This is intended to be a long running application that downloads all of the .ts files from the live stream to Minio/S3.  Also, every X seconds, it will take a snapshot of the live stream, send it to the [web](#web) application for computer vision magic and then update Slack with the snapshot IF there are people in the chairs.

More info at [downloader/README.md](downloader/README.md)

## SlackSlash

In addition to being the MOST POORLY NAMED APPLICATION ever, SlackSlash is a Sinatra app that handles a [Slack slash command](https://api.slack.com/legacy/custom-integrations/slash-commands) AND a Event Subscriptions for the channel that the Slack app is installed in.

More info at [slackslash/README.md](slackslash/README.md)

## Web
This is a Python [FastAPI](https://github.com/tiangolo/fastapi) web application that accepts an image via a Forms POST, processes the image and looks for common objects in it.  It returns a JSON payload with information about the image.

More info at [meatsweatsweb/README.md](meatsweatsweb/README.md)
