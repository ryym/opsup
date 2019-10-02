# typed: strict
# frozen_string_literal: true

module Opsup
  class CLI
    class OptionBuilder
      extend T::Sig

      sig { returns(Opsup::CLI::OptionBuilder) }
      def self.create
        new
      end

      DEFAULT_OPSWORKS_REGION = 'ap-northeast-1'

      sig { params(parser: OptionParser).returns(OptionParser) }
      def define_options(parser)
        parser.tap do |p|
          p.on('-s', '--stack STACK_NAME', 'target stack name')
          p.on('-m', '--mode MODE', Opsup::Config::MODES.join(' | ').to_s)
          p.on('--aws-cred KEY_ID,SECRET_KEY', 'AWS credentials')
          p.on('--opsworks-region REGION', "default: #{DEFAULT_OPSWORKS_REGION}")
          p.on('-d', '--dryrun')
        end
      end

      sig do
        params(
          env_vars: T::Hash[String, T.nilable(String)],
        ).returns(T::Hash[Symbol, T.untyped])
      end
      def options_from_env_vars(env_vars)
        [
          %w[stack STACK],
          %w[mode MODE],
          %w[aws-cred AWS_CRED],
          %w[opsworks-region OPSWORKS_REGION],
          %w[dryrun DRYRUN],
        ].each_with_object({}) do |(key, env_key), obj|
          value = env_vars["OPSUP_#{env_key}"]
          obj[key.to_sym] = value if value
        end
      end

      sig { params(options: T::Hash[Symbol, T.untyped]).returns(Opsup::Config) }
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
