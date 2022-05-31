# Chuspace

Chuspace is a collaborative blogging platform powered by Git and owned by authors:

- offering true content and design ownership
- works with any static site framework that speaks markdown
- community
- quality content
- Premium publications
- Multiple publications
- Realtime contribution and collaboration
- custom domains and hosting

Started out as a response to Medium editor being not so coding friendly back in 2015.

In short, it's combination of Google(indexing and search), Github (Versioning and Content storage) and Medium (Simple reading experience).

## Tech stack

Chuspace is built on the popular Ruby on Rails framework and is by design a monolith.

**Backend**

- Ruby 3.1+
- Ruby on Rails
- Postgresql

**Frontend**

- Web components
- Prosemirror
- Turbo

## Getting started

Install Redis

```
brew update
brew install redis
brew services start redis
```

Then run the following

```bash
git clone git@github.com:chuspace/chuspace.git
cd chuspace
bundle
yarn
bundle exec rails db:drop db:create db:migrate db:seed
./chu start
```

Visit http://localhost:3000

You can now create an account using Github, Gitlab, Bitbucket or Email.

## Deployment

```bash
convox rack params set proxy_protocol=true node_capacity_type=spot node_type=c5.large
```
