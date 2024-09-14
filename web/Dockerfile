FROM ruby:3.2.5

RUN apt-get update -qq && apt-get install -y \
	build-essential \
	libpq-dev

WORKDIR /web

COPY Gemfile /web/Gemfile
COPY server.rb /web/server.rb

RUN bundle install

CMD ["ruby", "/web/server.rb"]