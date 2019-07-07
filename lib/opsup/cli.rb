# frozen_string_literal: true

require 'optparse'

module Opsup
  class CLI
    private_class_method :new

    def self.create
      new(
        runner: Opsup::Runner.create,
        option_builder: Opsup::CLI::OptionBuilder.create,
      )
    end

    def initialize(runner:, option_builder:)
      @runner = runner
      @option_builder = option_builder
    end

    def run(argv)
      parser = create_parser
      @option_builder.define_options(parser)

      options = {}
      begin
        # It automatically exists with a help message if user specified the options for that.
        commands = parser.parse(argv, into: options)
      rescue OptionParser::MissingArgument => e
        puts e.message
        return false
      end

      begin
        config = @option_builder.generate_config(options)
        @runner.run(commands, config)
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
            #{@runner.available_commands.join(', ')}
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

      def define_options(parser)
        parser.tap do |p|
          p.on('-s', '--stack STACK_NAME')
          p.on('--aws-cred KEY_ID,SECRET_KEY')
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

        Opsup::Config.new(
          stack: options[:stack],
          aws_access_key_id: aws_key_id,
          aws_secret_access_key: aws_secret,
        )
      end
    end
  end
end
