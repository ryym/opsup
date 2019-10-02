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
      )
    end

    sig { params(app: Opsup::App, option_builder: Opsup::CLI::OptionBuilder).void }
    def initialize(app:, option_builder:)
      @app = T.let(app, Opsup::App)
      @option_builder = T.let(option_builder, Opsup::CLI::OptionBuilder)
    end

    sig { params(argv: T::Array[String]).returns(T::Boolean) }
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
