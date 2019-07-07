# frozen_string_literal: true

require 'optparse'

module Opsup
  class CLI
    HELP_CMDS = %w[-h --help].freeze

    def run(argv)
      parser = build_parser

      if help_wanted?(argv)
        exit_with_help(parser)
        return false
      end

      params = {}

      begin
        args = parser.parse(argv, into: params)
      rescue OptionParser::MissingArgument => e
        puts e.message
        return false
      end

      p args
      p params

      true
    end

    private def build_parser
      OptionParser.new.tap do |p|
        p.on('-s', '--stack STACK_NAME') { |v| v }
      end
    end

    private def help_wanted?(argv)
      argv.any? { |v| HELP_CMDS.include?(v) }
    end

    private def exit_with_help(parser)
      puts <<~HELP
        opsup runs commands for your OpsWorks stacks

      HELP
      parser.parse!([HELP_CMDS[0]])
    end
  end
end
