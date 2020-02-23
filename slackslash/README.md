# SlackSlash

This is 2020's worst named application per Stack Overflow.  It's a [SinatraRB](http://sinatrarb.com/) that handles a [Slack slash command](https://api.slack.com/legacy/custom-integrations/slash-commands) and incoming [Slack events](https://api.slack.com/events-api) from specific channels.

## Tests

This app has no tests because this is a silly project.  Maybe we'll add them later, but if something breaks, it's JUST MEATSWEATS.

## Running

Running this locally is as simple as installing the gems and running puma.  We use [rerun](https://github.com/alexch/rerun) to automatically reload the app when files change.

This application uses code in the ../lib folder as well.

```bash
bundle install
bundle exec rerun --dir ../lib/,./ puma
```

If you want to, you can run this in a container locally too.

Go to the root directory of this repo and build the container in the docker folder named [slackslash.Dockerfile](../docker/slackslash.Dockerfile).

```
docker build -t slackslash -f docker/slackslash.Dockerfile .
docker run -d --name slackslash -p 9292:9292 slackslash
```

The container will then listen on port 9292.

The downside to this is you need to rebuild the container anytime you change the files, so not sure this is that cool.

## Deployment

This has a Dockerfile for building a container.  This is running on a HashiPiCluster in Patrick's office.  To build this, you need to have a newer version of Docker Desktop (to get access to the [buildx](https://docs.docker.com/buildx/working-with-buildx/) command).

Again, from the root of the repo, run this command:

```
docker buildx build --platform linux/arm/v7 -t registry.veverka.net/slackslash --push -f docker/slackslash.Dockerfile .
```

This assumes you have access to the internal docker registry that lives at registry.veverka.net.  If you don't, maybe don't run this command?
