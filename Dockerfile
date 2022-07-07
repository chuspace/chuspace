FROM ruby:3.1-alpine

ENV LANG=C.UTF-8 \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3 \
  RAILS_ENV=production \
  NODE_ENV=production \
  BOOTSNAP_CACHE_DIR='tmp/bootsnap-cache' \
  RAILS_SERVE_STATIC_FILES='yes' \
  GEM_HOME=/app/.bundle \
  BUNDLE_PATH=$GEM_HOME \
  BUNDLE_BIN=/app/.bundle/bin \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3 \
  PATH=/app/bin:$PATH

RUN addgroup -S deploy && adduser -S deploy -G deploy

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

# bundle and yarn install
COPY --chown=deploy:deploy Gemfile Gemfile.lock package.json yarn.lock ./
RUN gem install bundler && bundle check || (bundle config set --local without 'development test' && bundle install)
RUN rm -rf node_modules && yarn install --check-files --frozen-lockfile

COPY --chown=deploy:deploy . .

ARG SECRET_KEY_BASE=fakekeyforassets

RUN  mv config/credentials/production.yml.enc ./config/credentials/production.yml.enc.backup && \
     mv config/credentials/production.sample.yml.enc ./config/credentials/production.yml.enc && \
     mv config/credentials/production.sample.key ./config/credentials/production.key

RUN bin/rails assets:clobber && bin/rails assets:precompile \
  && yarn cache clean \
  && (rm -rf /tmp/* || true) \
  && rm -rf $BUNDLE_PATH/*.gem \
  && find $BUNDLE_PATH/ruby -name "*.c" -delete \
  && find $BUNDLE_PATH/ruby -name "*.o" -delete \
  && find $BUNDLE_PATH/ruby -name ".git"  -type d -prune -exec rm -rf {} + \
  && rm -rf /app/.bundle/ruby/*/cache \
  && rm -rf /app/node_modules

USER deploy

ENV RACK_ENV=production
ENV RAILS_LOG_TO_STDOUT=enabled
ENV RAILS_SERVE_STATIC_FILES=enabled
