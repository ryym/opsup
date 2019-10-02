# typed: strict
# frozen_string_literal: true

require_relative 'stack_operator/command_deployer'

module Opsup
  class StackOperator
    extend T::Sig

    sig { params(opsworks: Aws::OpsWorks::Client).returns(Opsup::StackOperator) }
    def self.create(opsworks:)
      new(
        opsworks: opsworks,
        logger: Opsup::Logger.instance,
      )
    end

    sig { params(opsworks: Aws::OpsWorks::Client, logger: ::Logger).void }
    def initialize(opsworks:, logger:)
      @opsworks = T.let(opsworks, Aws::OpsWorks::Client)
      @logger = T.let(logger, ::Logger)
    end

    sig do
      params(
        stack_name: String,
        mode: Symbol,
        dryrun: T::Boolean,
      ).returns(StackOperator::CommandDeployer)
    end
    def new_deployer(stack_name:, mode:, dryrun: false)
      # Find the target stack.
      @logger.debug('Verifying the specified stack exists...')
      stacks = @opsworks.describe_stacks.stacks
      stack = stacks.find { |s| s.name == stack_name }
      raise Opsup::Error, "Stack #{stack_name} does not exist" if stack.nil?

      # Find the stack's apps.
      @logger.debug('Verifying the stack has at least one app...')
      apps = @opsworks.describe_apps(stack_id: stack.stack_id).apps
      raise Opsup::Error, "#{stack_name} has no apps" if apps.empty?

      # Find the instances to be updated.
      @logger.debug('Finding all working instances in the stack...')
      instances = @opsworks.describe_instances(stack_id: stack.stack_id).instances
      instances = instances.reject { |inst| inst.status == 'stopped' }

      raise Opsup::Error, 'No available instances found' if instances.empty?

      @logger.debug(
        "#{instances.size} #{instances.size == 1 ? 'instance is' : 'instances are'} found",
      )

      config = StackOperator::CommandDeployer::Config.new(
        stack: stack,
        mode: mode,
        # Currently Opsup deploys only the first app by default.
        app: apps.first,
        instance_ids: instances.map(&:instance_id),
        dryrun: dryrun,
      )
      StackOperator::CommandDeployer.create(
        config: config,
        opsworks: @opsworks,
        logger: @logger,
      )
    end
  end
end
