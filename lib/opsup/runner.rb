# frozen_string_literal: true

module Opsup
  class Runner
    private_class_method :new

    def self.create
      new(
        logger: Opsup::Logger.instance,
      )
    end

    def initialize(logger:)
      @logger = logger
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

    def run(commands, config)
      validate_commands(commands)

      @logger.debug("Running #{commands} with #{config.to_h}")
    end

    private def validate_commands(commands)
      raise Opsup::Error, 'No commands specified' if commands.empty?

      unknown_cmds = commands - AVAILABLE_COMMANDS
      raise Opsup::Error, "Unknown commands: #{unknown_cmds.join(' ')}" unless unknown_cmds.empty?
    end
  end
end
