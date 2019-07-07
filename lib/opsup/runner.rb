# frozen_string_literal: true

module Opsup
  class Runner
    private_class_method :new

    def self.create
      new
    end

    AVAILABLE_COMMANDS = %w[
      update_cookbooks
      setup
      configure
      deploy
    ].freeze

    def available_commands
      AVAILABLE_COMMANDS
    end

    def run(commands, _params)
      raise Opsup::Error, 'No commands specified' if commands.empty?

      unknown_cmds = commands - AVAILABLE_COMMANDS
      raise Opsup::Error, "Unknown commands: #{unknown_cmds.join(' ')}" if !unknown_cmds.empty?

      puts "Running #{commands}"
    end
  end
end
