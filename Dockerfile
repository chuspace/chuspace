FROM ruby:3.1.3-alpine

ENV LANG=C.UTF-8 \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3 \
  RAILS_ENV=$RAILS_ENV \
  NODE_ENV=$RAILS_ENV \
  RAILS_LOG_TO_STDOUT=enabled \
  BOOTSNAP_CACHE_DIR='tmp/bootsnap-cache' \
  RAILS_SERVE_STATIC_FILES='yes' \
  WORK_ROOT=/var \
  RAILS_ROOT=$WORK_ROOT/www/ \
  GEM_HOME=$WORK_ROOT/bundle \
  BUNDLE_BIN=$GEM_HOME/gems/bin \
  PATH=$GEM_HOME/bin:$BUNDLE_BIN:$PATH \
  ASSET_HOST=https://assets.chuspace.com \
  RAILS_MASTER_KEY=$RAILS_MASTER_KEY

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
WORKDIR $RAILS_ROOT

# bundle and yarn install
COPY Gemfile Gemfile.lock package.json yarn.lock ./
RUN gem install bundler && bundle check || bundle install --without development test
RUN yarn install --check-files --frozen-lockfile

COPY . $RAILS_ROOT

RUN bin/rails assets:clobber && bin/rails assets:precompile && yarn cache clean
