FROM ruby:3.1-alpine

ARG RAILS_SERVE_STATIC_FILES 'yes'
ENV NODE_ENV 'production'
ENV RAILS_ENV 'production'
ENV BOOTSNAP_CACHE_DIR 'tmp/bootsnap-cache'

RUN --mount=type=secret,id=RAILS_MASTER_KEY \
    --mount=type=secret,id=DATABASE_URL \
    export RAILS_MASTER_KEY=$(cat /run/secrets/RAILS_MASTER_KEY) && \
    export DATABASE_URL=$(cat /run/secrets/DATABASE_URL) && \

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
WORKDIR /app

# bundle install
COPY Gemfile Gemfile.lock ./
RUN gem install bundler
RUN bundle check || (bundle install --without development test --jobs=4 --retry=3)

# yarn install
COPY package.json yarn.lock ./
RUN rm -rf node_modules
RUN yarn install --check-files --frozen-lockfile

COPY . .

RUN bundle exec rake assets:precompile
