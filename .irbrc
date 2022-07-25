# Prepend the environment name to each line of the prompt.
rails_env = Rails.env

# Add extra visual warning (caps, bold, red font) when in
# production.
if rails_env.production?
  require "colorize"
  display_rails_env = rails_env.upcase.colorize(:red).bold
else
  display_rails_env = rails_env.capitalize
end

IRB.conf[:PROMPT][:RAILS_ENV] = {
  PROMPT_I: "#{display_rails_env} (%m):%03n:%i> ",
  PROMPT_N: "#{display_rails_env} (%m):%03n:%i> ",
  PROMPT_S: "#{display_rails_env} (%m):%03n:%i%l ",
  PROMPT_C: "#{display_rails_env} (%m):%03n:%i* ",
  RETURN:   "=> %sn"
}

IRB.conf[:PROMPT_MODE] = :RAILS_ENV
IRB.conf[:USE_AUTOCOMPLETE] = false
