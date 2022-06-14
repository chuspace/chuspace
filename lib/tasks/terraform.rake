# frozen_string_literal: true

namespace :terraform do
  task :run, [:command] do |t, args|
    command  = args[:command].to_sym
    resource_path = Rails.root.join("infra")

    case command.to_sym
    when :plan then  system "cd #{resource_path} && terraform init -upgrade && terraform plan"
    when :create then system "cd #{resource_path} && terraform apply"
    when :create_approve then system "cd #{resource_path} && terraform apply -auto-approve"
    when :destroy then system "cd #{resource_path} && terraform destroy -auto-approve"
    when :output then system "cd #{resource_path} && terraform output -json"
    else fail ArgumentError, 'Not a valid command'
    end
  end
end
