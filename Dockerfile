FROM ruby:2.5-alpine

# eventmachine requirements, as seen at https://github.com/eventmachine/eventmachine/wiki/Building-EventMachine
RUN apk --update add g++ musl-dev make

WORKDIR /app
COPY Gemfile* ./
RUN bundle install
COPY . .

CMD bundle exec ruby application.rb -s -e prod -p 3000
EXPOSE 3000