# frozen_string_literal: true

PROVIDERS = {
  aws: %w[
    aws_eu_west
    aws_eu_central
    aws_apac_south
    aws_apac_southeast
  ],
  do: %w[
    do_us_west
    do_us_east
    do_apac_sgp
  ]
}

namespace :terraform do
  task :deploy do |t, args|
    resource_path = Rails.root.join('infra')
    deploy_creds  = Rails.application.credentials.deploy

    vars = "-var='aws_access_key_id=#{deploy_creds.dig(:aws, :access_key_id)}' -var='aws_secret_access_key=#{deploy_creds.dig(:aws, :secret_access_key)}' -var='docker_access_token=#{deploy_creds.dig(:docker, :access_token)}' -var='logtail_token=#{deploy_creds.dig(:logtail, :access_token)}' -var='do_token=#{deploy_creds.dig(:do, :access_token)}'"

    puts "\n"
    puts 'Choose provider'.green
    puts PROVIDERS.keys.map.with_index { |provider, index| "#{index + 1}.#{provider}" }.join("\n")

    provider = gets.chomp.to_i

    regions = case provider
              when 1
                puts "\n"
      puts 'Choose AWS region'.green
      PROVIDERS[:aws]
              when 2
                puts "\n"
      puts 'Choose DO region'.green
      ROVIDERS[:do]
    else
                puts "\n\n Provider not found!!".red
      exit 1
    end

    puts regions.map.with_index { |region, index| "#{index + 1}.#{region}" }.join("\n")
    region = regions[gets.chomp.to_i - 1]

    if region.blank?
      puts "\n\n Region not found!!".red
      exit 1
    end

    system "cd #{resource_path} && terraform apply -replace=module.#{region}.module.aws_instance.aws_instance.app[0] -replace=module.#{region}.module.aws_instance.aws_instance.app[1] #{vars}"
  end
end

namespace :terraform do
  task :refresh do |t, args|
    resource_path = Rails.root.join('infra')
    deploy_creds  = Rails.application.credentials.deploy

    vars = "-var='aws_access_key_id=#{deploy_creds.dig(:aws, :access_key_id)}' -var='aws_secret_access_key=#{deploy_creds.dig(:aws, :secret_access_key)}' -var='docker_access_token=#{deploy_creds.dig(:docker, :access_token)}' -var='logtail_token=#{deploy_creds.dig(:logtail, :access_token)}' -var='do_token=#{deploy_creds.dig(:do, :access_token)}'"
    system "cd #{resource_path} && terraform refresh #{vars}"
  end
end
