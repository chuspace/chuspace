FROM ruby:3.1-alpine

ENV LANG=C.UTF-8 \
  BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3 \
  RAILS_ENV=production \
  NODE_ENV=production \
  BOOTSNAP_CACHE_DIR='tmp/bootsnap-cache' \
  RAILS_SERVE_STATIC_FILES='yes'

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
RUN gem install bundler && bundle check || (bundle install --without development test --jobs=4 --retry=3)

# yarn install
COPY package.json yarn.lock ./
RUN rm -rf node_modules && yarn install --check-files --frozen-lockfile

COPY . .

ARG SECRET_KEY_BASE=fakekeyforassets \
    RAILS_MASTER_KEY=fakemasterkey \
    DATABASE_URL=mysql2://localhost:3306/chuspace

RUN bin/rails assets:clobber && bundle exec rails assets:precompile

ENTRYPOINT ["./entrypoint.sh"]

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
