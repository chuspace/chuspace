FROM ruby:3.1.3-alpine

ENV LANG=C.UTF-8
ENV RAILS_ENV=production
ENV NODE_ENV=production

RUN apk del gmp-dev libstdc++ \
  && apk -U upgrade \
  && apk add --repository https://dl-cdn.alpinelinux.org/alpine/edge/main/ --no-cache \
    gmp-dev \
    libstdc++ \
    nodejs \
    npm \
    vips-dev \
    libffi-dev \
    bash \
    build-base \
    tzdata \
    libxslt-dev \
    libxml2-dev \
    gcc \
    musl-dev \
    mariadb-dev \
    mariadb-connector-c-dev \
    git \
    yarn

# set working directory
WORKDIR /src/app
COPY . /src/app

RUN bundle config set --local path '/usr/local/bundle' && bundle config set --local with "${RAILS_ENV}" && bundle config set --local without 'development test'
RUN gem install bundler
RUN bundle install --jobs=4 --retry=5
RUN yarn install
RUN bin/rails assets:clobber && bin/rails assets:precompile
