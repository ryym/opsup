# typed: strict
# frozen_string_literal: true

module Opsup
  class App
    extend T::Sig

    sig { returns(Opsup::App) }
    def self.create
      new(logger: Opsup::Logger.instance)
    end

    sig { params(logger: ::Logger).void }
    def initialize(logger:)
      @logger = T.let(logger, ::Logger)
    end

    AVAILABLE_COMMANDS = T.let(
      %w[
        upload_cookbooks
        update_cookbooks
        setup
        configure
        deploy
      ].freeze,
      T::Array[String],
    )

    sig { returns(T::Array[String]) }
    def available_commands
      AVAILABLE_COMMANDS
    end

    sig { params(commands: T::Array[String], config: Opsup::Config).void }
    def run(commands, config)
      validate_commands(commands)
      @logger.warn('Starting in DRYRUN MODE') if config.dryrun
      @logger.info("Commands: #{commands.join(',')}, Stack: #{config.stack_name}")
      @logger.debug("Configuration details: #{config.to_h}")

      opsworks = new_opsworks_client(config)
      stack_operator = Opsup::StackOperator.create(opsworks: opsworks)
      deployer = stack_operator.new_deployer(
        stack_name: config.stack_name,
        mode: config.running_mode,
        dryrun: config.dryrun,
      )

      commands.each do |command|
        if command == 'upload_cookbooks'
          upload_cookbooks(config)
          next
        end
        deployer.run_command(command_to_opsworks_command(command))
      end
    ensure
      msg = 'Finished' + (config.dryrun ? ' (DRYRUN MODE)' : '')
      @logger.info(msg)
    end

    sig { params(commands: T::Array[String]).void }
    private def validate_commands(commands)
      raise Opsup::Error, 'No commands specified' if commands.empty?

      unknown_cmds = commands - AVAILABLE_COMMANDS
      raise Opsup::Error, "Unknown commands: #{unknown_cmds.join(' ')}" unless unknown_cmds.empty?
    end

    sig { params(config: Opsup::Config).returns(Aws::OpsWorks::Client) }
    private def new_opsworks_client(config)
      creds = Aws::Credentials.new(config.aws_access_key_id, config.aws_secret_access_key)
      Aws::OpsWorks::Client.new(region: config.opsworks_region, credentials: creds)
    end

    # Assumes the command is a valid value.
    sig { params(command: String).returns(String) }
    private def command_to_opsworks_command(command)
      command == 'update_cookbooks' ? 'update_custom_cookbooks' : command
    end

    sig { params(config: Opsup::Config).void }
    def upload_cookbooks(config)
      if config.cookbook_url.nil?
        raise Opsup::Error, 'cookbook URL is required to run upload_cookbooks'
      end
      if config.s3_bucket_name.nil?
        raise Opsup::Error, 'S3 Bucket name is required to run upload_cookbooks'
      end

      s3_object_config = CookbookUploader::S3ObjectConfig.new(
        bucket_name: T.must(config.s3_bucket_name),
        key: "cookbook_#{config.stack_name}.tar.gz",
      )

      cookbook_uploader = CookbookUploader.create(s3: new_s3_client(config), config: config)
      cookbook_uploader.build_and_upload(
        cookbook_url: T.must(config.cookbook_url),
        s3_object_config: s3_object_config,
      )
    end

    sig { params(config: Opsup::Config).returns(Aws::S3::Client) }
    private def new_s3_client(config)
      creds = Aws::Credentials.new(config.aws_access_key_id, config.aws_secret_access_key)
      Aws::S3::Client.new(region: config.s3_region, credentials: creds)
    end
  end
end
