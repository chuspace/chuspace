FROM ruby:3.1.2-buster as development

ENV RAILS_ENV development

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -\
  && apt-get update -qq && apt-get install -qq --no-install-recommends nodejs postgresql-client
  && apt-get upgrade -qq \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*\
  && npm install -g yarn@1

# set working directory
WORKDIR /usr/src/app

# bundle install
COPY Gemfile Gemfile.lock ./
RUN bundle install

# yarn install
COPY package.json yarn.lock ./
RUN yarn install --check-files

# copy the rest of the app
COPY . .

CMD ["rails", "server", "-b", "0.0.0.0"]

EXPOSE 3000

from development as production

ARG SECRET_KEY_BASE
ARG RAILS_MASTER_KEY
ARG DATABASE_URL

ENV NODE_ENV production
ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES true

RUN rake assets:precompile
