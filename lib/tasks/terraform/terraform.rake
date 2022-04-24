# frozen_string_literal: true

namespace :terraform do
  resources = %w[app aurora cache database database_replica security_group vpc].freeze

  namespace :app do
    task :create do
      Rake.application.invoke_task('terraform:run[app, create]')
    end

    task :plan do
      Rake.application.invoke_task('terraform:run[app, plan]')
    end

    task :destroy do
      Rake.application.invoke_task('terraform:run[app, destroy]')
    end

    task :output do
      Rake.application.invoke_task('terraform:output[app]')
    end

    task :ip do
      Rake.application.invoke_task('terraform:output[app, public_elastic_ip]')
    end
  end

  namespace :aurora do
    task :create do
      Rake.application.invoke_task('terraform:run[aurora, create]')
    end

    task :plan do
      Rake.application.invoke_task('terraform:run[aurora, plan]')
    end

    task :destroy do
      Rake.application.invoke_task('terraform:run[aurora, destroy]')
    end

    task :output do
      Rake.application.invoke_task('terraform:output[aurora]')
    end

    task :endpoint do
      Rake.application.invoke_task('terraform:output[aurora, endpoint]')
    end
  end

  namespace :database do
    task :create do
      Rake.application.invoke_task('terraform:run[database, create]')
    end

    task :plan do
      Rake.application.invoke_task('terraform:run[database, plan]')
    end

    task :destroy do
      Rake.application.invoke_task('terraform:run[database, destroy]')
    end

    task :output do
      Rake.application.invoke_task('terraform:output[database]')
    end

    task :endpoint do
      Rake.application.invoke_task('terraform:output[database_replica, endpoint]')
    end
  end

  namespace :database_replica do
    task :create do
      Rake.application.invoke_task('terraform:run[database_replica, create]')
    end

    task :plan do
      Rake.application.invoke_task('terraform:run[database_replica, plan]')
    end

    task :destroy do
      Rake.application.invoke_task('terraform:run[database_replica, destroy]')
    end

    task :output do
      Rake.application.invoke_task('terraform:output[database_replica]')
    end

    task :endpoint do
      Rake.application.invoke_task('terraform:output[database_replica, endpoint]')
    end
  end

  namespace :global_accelerator do
    task :create do
      Rake.application.invoke_task('terraform:run[database, create]')
    end

    task :plan do
      Rake.application.invoke_task('terraform:run[database, plan]')
    end

    task :destroy do
      Rake.application.invoke_task('terraform:run[database, destroy]')
    end

    task :output do
      Rake.application.invoke_task('terraform:output[database]')
    end
  end

  namespace :security_group do
    task :create do
      Rake.application.invoke_task('terraform:run[security_group, create]')
    end

    task :plan do
      Rake.application.invoke_task('terraform:run[security_group, plan]')
    end

    task :destroy do
      Rake.application.invoke_task('terraform:run[security_group, destroy]')
    end

    task :output do
      Rake.application.invoke_task('terraform:output[security_group]')
    end
  end

  namespace :vpc do
    task :create do
      Rake.application.invoke_task('terraform:run[vpc, create]')
    end

    task :plan do
      Rake.application.invoke_task('terraform:run[vpc, plan]')
    end

    task :destroy do
      Rake.application.invoke_task('terraform:run[vpc, destroy]')
    end

    task :output do
      Rake.application.invoke_task('terraform:output[vpc]')
    end
  end

  # Private tasks
  task :run, [:resource, :command] do |t, args|
    resource = args[:resource]
    command  = args[:command]
    fail ArgumentError, 'Not valid resource' unless resources.include?(resource)
    resource_paths = Dir[Rails.root.join("infra/production/#{resource}/*")]

    resource_paths.each do |resource_path|
      region = File.basename(resource_path)
      puts "#{command} #{resource} in #{region} region"
      commands = case command.to_sym
                 when :plan then  system "cd #{resource_path} && terraform init -upgrade && terraform plan"
                 when :create then system "cd #{resource_path} && terraform apply -auto-approve"
                 when :destroy then system "cd #{resource_path} && terraform destroy -auto-approve"
                 else fail ArgumentError, 'Not a valid command'
      end


      puts "\n\n"
    end
  end

  task :output, [:resource, :raw] do |t, args|
    resource = args[:resource]
    fail ArgumentError, 'Not valid resource' unless resources.include?(resource)
    resource_paths = Dir[Rails.root.join("infra/production/#{resource}/*")]
    resource_paths.map do |resource_path|
      region = File.basename(resource_path)
      puts region

      if args[:raw]
        puts `cd #{resource_path} && terraform output -raw #{args[:raw]}`
      else
        system "cd #{resource_path} && terraform output -json"
      end
    end
  end
end
