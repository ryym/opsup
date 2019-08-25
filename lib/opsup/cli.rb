# typed: true
# frozen_string_literal: true

require 'optparse'

module Opsup
  class CLI
    private_class_method :new

    def self.create
      new(
        app: Opsup::App.create,
        option_builder: Opsup::CLI::OptionBuilder.create,
      )
    end

    def initialize(app:, option_builder:)
      @app = app
      @option_builder = option_builder
    end

    def run(argv)
      parser = create_parser
      @option_builder.define_options(parser)

      options = {}
      begin
        # It automatically exits with a help message if necessary.
        commands = parser.parse(argv, into: options)
      rescue OptionParser::MissingArgument => e
        puts e.message
        return false
      end

      begin
        config = @option_builder.generate_config(options)
        @app.run(commands, config)
      rescue Opsup::Error => e
        puts "Error: #{e.message}"
        return false
      end

      true
    end

    private def create_parser
      # ref: https://docs.ruby-lang.org/en/2.1.0/OptionParser.html
      OptionParser.new do |p|
        p.version = Opsup::VERSION
        p.banner = <<~BANNER
          CLI to run Chef commands easily for your OpsWorks stacks.
          Usage:
            opsup [options] [commands...]
          Commands:
            #{@app.available_commands.join(', ')}
          Example:
            opsup -s stack-name deploy

          Options:
        BANNER
      end
    end

    class OptionBuilder
      private_class_method :new

      def self.create
        new
      end

      DEFAULT_OPSWORKS_REGION = 'ap-northeast-1'

      def define_options(parser)
        parser.tap do |p|
          p.on('-s', '--stack STACK_NAME', 'target stack name')
          p.on('-m', '--mode MODE', Opsup::Config::MODES.join(' | ').to_s)
          p.on('--aws-cred KEY_ID,SECRET_KEY', 'AWS credentials')
          p.on('--opsworks-region REGION', "default: #{DEFAULT_OPSWORKS_REGION}")
          p.on('-d', '--dryrun')
        end
      end

      def generate_config(options)
        %w[stack aws-cred].each do |key|
          raise Opsup::Error, "missing required option: --#{key}" unless options[key.to_sym]
        end

        aws_key_id, aws_secret = options[:"aws-cred"].split(',')
        if aws_key_id.nil? || aws_secret.nil?
          raise Opsup::Error, "aws-cred must be 'key_id,secret_key' format"
        end

        mode = options[:mode]&.to_sym
        raise Opsup::Error, "invalid mode: #{mode}" if mode && !Opsup::Config::MODES.include?(mode)

        Opsup::Config.new(
          stack_name: options[:stack],
          aws_access_key_id: aws_key_id,
          aws_secret_access_key: aws_secret,
          opsworks_region: options[:"opsworks-region"] || DEFAULT_OPSWORKS_REGION,
          running_mode: mode,
          dryrun: options[:dryrun] || false,
        )
      end
    end
  end
end
