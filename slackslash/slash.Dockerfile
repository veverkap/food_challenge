FROM ruby:latest

RUN apt-get update -qq && apt-get install ffmpeg -y

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./

RUN gem install bundler

RUN bundle install

COPY main.rb config.ru downloader.rb ./

CMD ["puma"]
