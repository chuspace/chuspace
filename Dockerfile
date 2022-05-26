FROM ruby:3.1-alpine

ARG SECRET_KEY_BASE
ARG RAILS_MASTER_KEY
ARG DATABASE_URL
ENV NODE_ENV production
ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV BOOTSNAP_CACHE_DIR 'tmp/bootsnap-cache'

ARG REFRESHED_AT
ENV REFRESHED_AT $REFRESHED_AT

RUN apk del gmp-dev libstdc++ \
  && apk -U upgrade \
  && apk add --repository https://dl-cdn.alpinelinux.org/alpine/edge/main/ --no-cache \
    gmp-dev \
    libstdc++ \
    nodejs \
    npm \
    libffi-dev \
    build-base \
    tzdata \
    libxslt-dev \
    libxml2-dev \
    postgresql-dev \
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

RUN bundle exec rails assets:precompile

COPY . .

CMD ["rails", "server", "-b", "0.0.0.0"]

EXPOSE 3000
