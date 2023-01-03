FROM ruby:3.1.3-alpine

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

RUN gem install bundler && bundle check || bundle install --without development test
RUN yarn install --check-files --frozen-lockfile
RUN bundle exec assets:clobber && bundle exec assets:precompile && yarn cache clean
