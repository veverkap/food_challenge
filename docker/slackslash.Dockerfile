FROM ruby:latest

RUN apt-get update -qq && apt-get install ffmpeg -y

WORKDIR /usr/src/app

COPY slackslash/ ./

COPY lib/ /usr/src/lib

RUN gem install bundler

RUN bundle install


CMD ["puma"]
