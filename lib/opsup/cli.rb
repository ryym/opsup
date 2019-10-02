# typed: strict
# frozen_string_literal: true

require 'optparse'
require_relative 'cli/option_builder'

module Opsup
  class CLI
    extend T::Sig

    sig { returns(Opsup::CLI) }
    def self.create
      new(
        app: Opsup::App.create,
        option_builder: Opsup::CLI::OptionBuilder.create,
        env_vars: ENV.to_h,
      )
    end

    sig do
      params(
        app: Opsup::App,
        option_builder: Opsup::CLI::OptionBuilder,
        env_vars: T::Hash[String, T.nilable(String)],
      ).void
    end
    def initialize(app:, option_builder:, env_vars:)
      @app = T.let(app, Opsup::App)
      @option_builder = T.let(option_builder, Opsup::CLI::OptionBuilder)
      @env_vars = T.let(env_vars, T::Hash[String, T.nilable(String)])
    end

    sig { params(argv: T::Array[String]).returns(T::Boolean) }
    def run(argv)
      parser = create_parser
      @option_builder.define_options(parser)

      options = @option_builder.options_from_env_vars(@env_vars)
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

    sig { returns(OptionParser) }
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
  end
end
