# frozen_string_literal: true

namespace :terraform do
  resources = %w[instances databases security_groups vpcs].freeze

  namespace :instances do
    task :create do
      Rake.application.invoke_task('terraform:run[instances, create]')
    end

    task :plan do
      Rake.application.invoke_task('terraform:run[instances, plan]')
    end

    task :destroy do
      Rake.application.invoke_task('terraform:run[instances, destroy]')
    end

    task :output do
      Rake.application.invoke_task('terraform:output[instances]')
    end

    task :ip do
      Rake.application.invoke_task('terraform:output[instances, public_elastic_ip]')
    end
  end

  namespace :databases do
    task :create do
      Rake.application.invoke_task('terraform:run[databases, create]')
    end

    task :plan do
      Rake.application.invoke_task('terraform:run[databases, plan]')
    end

    task :destroy do
      Rake.application.invoke_task('terraform:run[databases, destroy]')
    end

    task :output do
      Rake.application.invoke_task('terraform:output[databases]')
    end

    task :endpoint do
      Rake.application.invoke_task('terraform:output[databases, endpoint]')
    end
  end

  namespace :global_accelerators do
    task :create do
      Rake.application.invoke_task('terraform:run[global_accelerators, create]')
    end

    task :plan do
      Rake.application.invoke_task('terraform:run[global_accelerators, plan]')
    end

    task :destroy do
      Rake.application.invoke_task('terraform:run[global_accelerators, destroy]')
    end

    task :output do
      Rake.application.invoke_task('terraform:output[global_accelerators]')
    end
  end

  namespace :security_groups do
    task :create do
      Rake.application.invoke_task('terraform:run[security_groups, create]')
    end

    task :plan do
      Rake.application.invoke_task('terraform:run[security_groups, plan]')
    end

    task :destroy do
      Rake.application.invoke_task('terraform:run[security_groups, destroy]')
    end

    task :output do
      Rake.application.invoke_task('terraform:output[security_groups]')
    end
  end

  namespace :vpcs do
    task :create do
      Rake.application.invoke_task('terraform:run[vpcs, create]')
    end

    task :plan do
      Rake.application.invoke_task('terraform:run[vpcs, plan]')
    end

    task :destroy do
      Rake.application.invoke_task('terraform:run[vpcs, destroy]')
    end

    task :output do
      Rake.application.invoke_task('terraform:output[vpcs]')
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
