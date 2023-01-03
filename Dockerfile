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

# bundle and yarn install
COPY Gemfile Gemfile.lock package.json yarn.lock ./
RUN gem install bundler && bundle check || bundle install --without development test
RUN yarn install --check-files --frozen-lockfile

COPY . /src/app

RUN bin/rails assets:clobber && bin/rails assets:precompile && yarn cache clean
