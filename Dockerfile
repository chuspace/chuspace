FROM ruby:alpine

ENV LANG=C.UTF-8 \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3 \
  RAILS_ENV=production \
  NODE_ENV=production \
  RAILS_LOG_TO_STDOUT=enabled \
  BOOTSNAP_CACHE_DIR='tmp/bootsnap-cache' \
  RAILS_SERVE_STATIC_FILES='yes' \
  WORK_ROOT=/var \
  RAILS_ROOT=$WORK_ROOT/www/ \
  GEM_HOME=$WORK_ROOT/bundle \
  BUNDLE_BIN=$GEM_HOME/gems/bin \
  PATH=$GEM_HOME/bin:$BUNDLE_BIN:$PATH \
  ASSET_HOST=https://assets.chuspace.com

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
    yarn \
    ca-certificates

# set working directory
WORKDIR $RAILS_ROOT

# bundle and yarn install
COPY Gemfile Gemfile.lock package.json yarn.lock ./
RUN gem install bundler && bundle check || bundle install --without development test
RUN rm -rf node_modules && yarn install --check-files --frozen-lockfile

COPY . $RAILS_ROOT

ARG SECRET_KEY_BASE=fakekeyforassets

RUN  mv config/credentials/production.yml.enc ./config/credentials/production.yml.enc.backup && \
     mv config/credentials/production.sample.yml.enc ./config/credentials/production.yml.enc && \
     mv config/credentials/production.sample.key ./config/credentials/production.key

RUN bin/rails assets:clobber && bin/rails assets:precompile && yarn cache clean

RUN  rm -rf config/credentials/production.yml.enc && \
     mv config/credentials/production.yml.enc.backup ./config/credentials/production.yml.enc && \
     mv config/credentials/production.key ./config/credentials/production.sample.key

RUN apk del gmp-dev \
    libstdc++ \
    nodejs \
    npm \
    libffi-dev \
    build-base \
    git \
    yarn
