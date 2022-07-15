# frozen_string_literal: true

MaybeLater.config do |config|
    # Will be called if a block passed to MaybeLater.run raises an error
    config.on_error = ->(exception) { Rollbar.error(exception) }

    # Will run after each `MaybeLater.run {}` block, even if it errors
    config.after_each = -> {}

    # By default, tasks will run in a fixed thread pool. To run them in the
    # thread dispatching the HTTP response, set this to true
    config.inline_by_default = false

    # How many threads to allocate to the fixed thread pool (default: 5)
    config.max_threads = 5

    # If set to true, will invoke the after_reply tasks even if the server doesn't
    # provide an array of rack.after_reply array
    config.invoke_even_if_server_is_unsupported = true
  end
