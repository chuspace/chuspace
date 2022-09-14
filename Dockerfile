FROM ruby:3.1-alpine

ARG APP_NAME
ARG APP_REGION
ARG ASSET_HOST
ARG IMAGE_CDN_HOST
ARG AVATARS_CDN_HOST
ARG RAILS_SERVE_STATIC_FILES 'yes'
ENV NODE_ENV 'production'
ENV RAILS_ENV 'production'
ENV BOOTSNAP_CACHE_DIR 'tmp/bootsnap-cache'

ARG SECRET_KEY_BASE
ARG RAILS_MASTER_KEY
ARG DATABASE_URL
ARG DATABASE_REPLICA_URL

ARG REFRESHED_AT
ENV REFRESHED_AT $REFRESHED_AT

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
    mariadb-dev \
    git \
    yarn

# set working directory
WORKDIR /usr/src/app

# bundle install
COPY Gemfile Gemfile.lock ./
RUN gem install bundler
RUN bundle check || (bundle install --without development test --jobs=4 --retry=3)

# yarn install
COPY package.json yarn.lock ./
RUN yarn install --check-files --frozen-lockfile

COPY . .

RUN bundle exec rake assets:precompile

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

EXPOSE 3000
