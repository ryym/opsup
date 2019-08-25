# typed: true
# frozen_string_literal: true

require 'aws-sdk-opsworks'

module Opsup
  class App
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
      @logger.warn('Started in DRYRUN MODE') if config.dryrun
      @logger.debug("Running #{commands} with #{config.to_h}")

      opsworks = new_opsworks_client(config)
      opsworks_commands = commands.map { |c| command_to_opsworks_command(c) }

      stack_operator = Opsup::StackOperator.create(opsworks: opsworks)
      stack_operator.run_commands(
        opsworks_commands,
        stack_name: config.stack_name,
        mode: config.running_mode,
        dryrun: config.dryrun,
      )
    ensure
      @logger.warn('Finished in DRYRUN MODE') if config.dryrun
    end

    private def validate_commands(commands)
      raise Opsup::Error, 'No commands specified' if commands.empty?

      unknown_cmds = commands - AVAILABLE_COMMANDS
      raise Opsup::Error, "Unknown commands: #{unknown_cmds.join(' ')}" unless unknown_cmds.empty?
    end

    private def new_opsworks_client(config)
      creds = Aws::Credentials.new(config.aws_access_key_id, config.aws_secret_access_key)
      Aws::OpsWorks::Client.new(region: config.opsworks_region, credentials: creds)
    end

    # Assumes the command is a valid value.
    private def command_to_opsworks_command(command)
      command == 'update_cookbooks' ? 'update_custom_cookbooks' : command
    end
  end
end
