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

    # Returns base64 encoded string from markdown
    def compile(content:, username:)
      context.eval(
        <<~STR
          toYDoc("#{ApplicationController.helpers.escape_javascript(content)}", "#{username}")
        STR
      )
    end

    # Returns markdowns from base64 encoded string
    def parse(ydoc:)
      context.eval(
        <<~STR
          fromYDoc("#{ydoc}")
        STR
      )
    end
  end
end
