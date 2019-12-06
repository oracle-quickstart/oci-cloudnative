FROM ruby:2.3-alpine
RUN apk add --update nodejs g++ make
RUN gem install bundler

WORKDIR /usr/src/app
COPY Gemfile* ./
RUN bundle install

COPY . .

VOLUME /transfer
RUN bundle exec middleman build --clean

EXPOSE 4567
CMD ["bundle", "exec", "middleman", "server", "--watcher-force-polling"]