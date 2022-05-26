FROM ruby:3.1.2-buster as development

ARG DEBIAN_FRONTEND=noninteractive
ARG SECRET_KEY_BASE
ARG RAILS_MASTER_KEY
ARG DATABASE_URL
ENV NODE_ENV production
ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV BOOTSNAP_CACHE_DIR 'tmp/bootsnap-cache'

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -\
  && apt-get update -y && apt-get install -y gcc g++ make nodejs postgresql-client \
  && apt-get upgrade -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*\
  && npm install -g yarn@1

# set working directory
WORKDIR /usr/src/app

# bundle install
COPY Gemfile Gemfile.lock ./
RUN bundle check || (bundle install --without development test --jobs=4 --retry=3 && bundle clean)

# yarn install
COPY package.json yarn.lock ./
RUN yarn install --check-files --frozen-lockfile

RUN bundle execc rails assets:precompile

COPY . .

CMD ["rails", "server", "-b", "0.0.0.0"]

EXPOSE 3000
