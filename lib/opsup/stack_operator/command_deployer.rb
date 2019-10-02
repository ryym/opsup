# typed: strict
# frozen_string_literal: true

module Opsup
  class StackOperator
    class CommandDeployer
      extend T::Sig

      class Config < T::Struct
        const :stack, Aws::OpsWorks::Types::Stack
        const :mode, Symbol
        const :app, Aws::OpsWorks::Types::App
        const :instance_ids, T::Array[String]
        const :dryrun, T::Boolean
      end

      sig do
        params(
          config: Config,
          opsworks: Aws::OpsWorks::Client,
          logger: ::Logger,
        ).returns(Opsup::StackOperator::CommandDeployer)
      end
      def self.create(config:, opsworks:, logger:)
        new(config: config, opsworks: opsworks, logger: logger)
      end

      sig do
        params(
          config: Config,
          opsworks: Aws::OpsWorks::Client,
          logger: ::Logger,
        ).void
      end
      def initialize(config:, opsworks:, logger:)
        @config = T.let(config, Config)
        @opsworks = T.let(opsworks, Aws::OpsWorks::Client)
        @logger = T.let(logger, ::Logger)
      end

      sig { params(command: String).void }
      def run_command(command)
        mode = @config.mode
        instance_ids = @config.instance_ids
        dryrun = @config.dryrun

        @logger.info("Running #{command} command in #{mode} mode...")

        case mode
        when :parallel
          @logger.info("Creating single deployment for the #{instance_ids.size} instances...")
          create_deployment(command, instance_ids) unless dryrun
        when :serial
          instance_ids.each.with_index do |id, i|
            @logger.info("Creating deployment for instances[#{i}] (#{id})...")
            create_deployment(command, [id]) unless dryrun
          end
        when :one_then_all
          @logger.info("Creating deployment for the first instance (#{instance_ids[0]})...")
          create_deployment(command, [T.must(instance_ids[0])]) unless dryrun

          rest = T.must(instance_ids[1..-1])
          if !rest.empty?
            @logger.info("Creating deployment for the other #{rest.size} instances...")
            create_deployment(command, rest) unless dryrun
          else
            @logger.info('No other instances exist.')
          end
        else
          raise "Unknown running mode: #{mode}"
        end
      end

      sig do
        params(
          command: String,
          instance_ids: T::Array[String],
        ).void
      end
      private def create_deployment(command, instance_ids)
        res = @opsworks.create_deployment(
          stack_id: @config.stack.stack_id,
          app_id: @config.app.app_id,
          instance_ids: instance_ids,
          command: { name: command, args: {} },
        )

        @logger.info("Waiting deployment #{res.deployment_id}...")
        @opsworks.wait_until(:deployment_successful, {
          deployment_ids: [res.deployment_id],
        })

        nil
      end
    end
  end
end
