# frozen_string_literal: true

require 'aws-sdk-s3'

SitemapGenerator::Sitemap.default_host = ENV.fetch('CHUSPACE_URL')
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
SitemapGenerator::Sitemap.public_path = 'public/'

if Rails.env.production?
  SitemapGenerator::Sitemap.adapter =
    SitemapGenerator::AwsSdkAdapter.new(
      ENV['AWS_S3_BUCKET'],
      aws_access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID'),
      aws_secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY'),
      aws_region: 'eu-west-2'
    )

  SitemapGenerator::Sitemap.public_path = 'tmp/'
  SitemapGenerator::Sitemap.sitemaps_host = 'https://sitemaps.chuspace.com/'
end

SitemapGenerator::Sitemap.create do
  Post.order(:date).limit(1_000).find_each do |post|
    add publication_post_url(post.publication, post), lastmod: post.date, changefreq: 'daily'
  end

  User.order(:updated_at).limit(1_000).find_each do |user|
    add user_url(user), lastmod: user.updated_at, changefreq: 'daily'
  end

  Publication.order(:updated_at).limit(1_000).find_each do |publication|
    add publication_url(publication), lastmod: publication.updated_at, changefreq: 'daily'
  end
end
