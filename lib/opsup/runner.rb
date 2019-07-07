# frozen_string_literal: true

require 'aws-sdk-opsworks'

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

      opsworks = new_opsworks_client(config)

      @logger.debug('Verifying the specified stack exists...')
      stacks = opsworks.describe_stacks.stacks
      target_stack = stacks.find { |s| s.name == config.stack_name }
      raise Opsup::Error, "Stack #{config.stack_name} does not exist" if target_stack.nil?
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
  end
end
