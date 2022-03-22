# frozen_string_literal: true

require 'down/http'

module Ydoc
  class Compiler
    attr_reader :context

    def initialize
      source = <<-JS
        var global = global || this;
        var window = global || this;
        var self = self || this;
        var console = self || this;
        var setTimeout = function () {};
        window.setTimeout = setTimeout
        global.clearTimeout = global.clearTimeout || setTimeout;
        global.setTimeout = global.setTimeout || setTimeout;
        global.clearInterval = global.clearInterval || setTimeout;
      JS

      source += "\n\n" + Rails.root.join('app/lib/ydoc/compiler.js').read
      @context = ExecJS.compile(source)
    end

    def compile(markdown:, username:)
      context.eval(
        <<~MD
          toYDoc("#{ApplicationController.helpers.escape_javascript(markdown)}", "#{username}")
        MD
      )
    end
  end
end
