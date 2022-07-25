# frozen_string_literal: true

PRIMARY_REGION = 'aws_eu_west'

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

namespace :remote do
  resource_path = Rails.root.join('infra')
  deploy_creds  = Rails.application.credentials.deploy
  vars          = "-var='aws_access_key_id=#{deploy_creds.dig(:aws, :access_key_id)}' -var='aws_secret_access_key=#{deploy_creds.dig(:aws, :secret_access_key)}' -var='docker_access_token=#{deploy_creds.dig(:docker, :access_token)}' -var='logtail_token=#{deploy_creds.dig(:logtail, :access_token)}' -var='do_token=#{deploy_creds.dig(:do, :access_token)}'"

  task :db_restore do
    db_dir = Rails.root.join("tmp/backups/backup-#{Time.current.to_i}")
    system "DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rails db:drop db:create"
    system "pscale database dump chuspace-primary main --output #{db_dir}"

    Dir["#{db_dir}/**/*.sql"].each do |file|
      if file.include?('-schema')
        File.write("#{db_dir}/schema.sql", db_dir.join(file).read, File.size(db_dir.join(file)), mode: 'a')
      else
        File.write("#{db_dir}/data.sql", db_dir.join(file).read, File.size(db_dir.join(file)), mode: 'a')
      end
    end

    system "mysql -u root chuspace_development < #{db_dir}/schema.sql"
    system "mysql -u root chuspace_development < #{db_dir}/data.sql"
    system "rm -rf #{db_dir}"
    puts 'Database restored from production'
  end

  task :console do
    tmp_file = Rails.root.join('tmp/terraform.output')

    output = if tmp_file.exist?
      tmp_file.read
    else
      json = `cd #{resource_path} && terraform output -json`
      puts "Caching output".green
      File.write(Rails.root.join('tmp/terraform.output'), json)
      json
    end

    data = JSON.parse(output)
    primary_region = data.find { |region, value| region == "#{PRIMARY_REGION}_servers" }.second
    ip_address = primary_region['value'].sample

    puts "Connecting to #{ip_address}".green
    system "ssh ubuntu@#{ip_address} -t 'cd /home/ubuntu/app && docker run --env-file .env -it chuspace2/app:main bundle exec rails c'"
  end

  task :deploy do
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

  task :deploy_all do
    cmd  = "cd #{resource_path} && terraform apply #{vars}"

    PROVIDERS[:aws].each do |region|
      next if region == PRIMARY_REGION

      cmd += " -replace=module.#{region}.module.aws_instance.aws_instance.app[0] -replace=module.#{region}.module.aws_instance.aws_instance.app[1]"
    end

    PROVIDERS[:do].each do |region|
      cmd += " -replace=module.#{region}.module.do_instance.digitalocean_droplet.app[0] -replace=module.#{region}.module.do_instance.digitalocean_droplet.app[1]"
    end

    system cmd
  end

  task :deploy_primary do
    system "cd #{resource_path} && terraform apply #{vars} -replace=module.#{PRIMARY_REGION}.module.aws_instance.aws_instance.app[0] -replace=module.#{PRIMARY_REGION}.module.aws_instance.aws_instance.app[1]"
  end

  task :refresh do |t, args|
    system "cd #{resource_path} && terraform refresh #{vars}"
  end

  task :output do |t, args|
    `cd #{resource_path} && terraform output -json`
  end
end

