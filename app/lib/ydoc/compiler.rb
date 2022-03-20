# frozen_string_literal: true

require 'down/http'

module Ydoc
  class Compiler
    attr_reader :context

    def initialize
      source = <<-JS
        var global = global || this;
        var self = self || this;
        var console = self || this;
        global.clearTimeout = global.clearTimeout || function () {};
        global.setTimeout = global.setTimeout || function () {};
        global.clearInterval = global.clearInterval || function () {};
      JS

      source += "\n\n" + Rails.root.join('public/assets/lib/ydoc.js').read
      @context = ExecJS.compile(source)
    end

    def compile(markdown:)
      context.eval(
        <<~MD
          toYDoc("#{ApplicationController.helpers.escape_javascript(markdown)}")
        MD
      )
    end
  end
end
