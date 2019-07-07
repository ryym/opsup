# frozen_string_literal: true

require 'optparse'

module Opsup
  class CLI
    HELP_CMDS = %w[-h --help].freeze

    def initialize(runner: Opsup::Runner.create)
      @runner = runner
    end

    def run(argv)
      parser = build_parser

      if help_wanted?(argv)
        exit_with_help(parser)
        return false
      end

      params = {}
      begin
        commands = parser.parse(argv, into: params)
      rescue OptionParser::MissingArgument => e
        puts e.message
        return false
      end

      begin
        @runner.run(commands, params)
      rescue Opsup::Error => e
        puts "Error: #{e.message}"
        return false
      end

      true
    end

    private def build_parser
      OptionParser.new.tap do |p|
        p.on('-s', '--stack STACK_NAME')
      end
    end

    private def help_wanted?(argv)
      argv.any? { |v| HELP_CMDS.include?(v) }
    end

    private def exit_with_help(parser)
      puts <<~HELP
        Opsup runs commands for your OpsWorks stacks.
        Commands:
          #{@runner.available_commands.join(', ')}
        Example:
          opsup -s stack-name deploy

      HELP
      parser.parse!([HELP_CMDS[0]])
    end
  end
end
