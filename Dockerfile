FROM ruby:2.3.3

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs curl
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y nodejs && rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true 
ENV RACK_ENV production
ENV NPM_CONFIG_LOGLEVEL=error
ENV NPM_CONFIG_PRODUCTION=true
ENV NODE_VERBOSE=false
ENV NODE_ENV=production
ENV NODE_MODULES_CACHE=true

COPY www/Gemfile /usr/src/app/
COPY www/Gemfile.lock /usr/src/app/

RUN bundle config --global frozen 1
RUN gem install bundler
RUN bundle install --without development test

COPY www/ /usr/src/app

RUN mkdir -p /etc/nginx/conf.d/
COPY ./conf/nginx.conf /etc/nginx/conf.d/default.conf

RUN npm install -g yarn && cd client && yarn install
RUN cd ..
RUN bundle exec rake assets:precompile

EXPOSE 3000

CMD foreman start
