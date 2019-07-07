# frozen_string_literal: true

module Opsup
  class StackOperator
    private_class_method :new

    def self.create(opsworks:)
      new(
        opsworks: opsworks,
        logger: Opsup::Logger.instance,
      )
    end

    def initialize(opsworks:, logger:)
      @opsworks = opsworks
      @logger = logger
    end

    def run_commands(commands, stack_name:, mode:, dryrun: false)
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
      @logger.debug(
        "#{instances.size} #{instances.size == 1 ? 'instance is' : 'instances are'} found",
      )

      # Currently Opsup deploys only the first app by default.
      app = apps.first
      instance_ids = instances.map(&:instance_id)

      # Run the commands sequentially.
      commands.each do |command|
        @logger.info("Running #{command} command in #{mode} mode...")
        run_command(
          command,
          dryrun: dryrun,
          mode: mode,
          stack: stack,
          app: app,
          instance_ids: instance_ids,
        )
      end
    end

    private def run_command(command, dryrun:, mode:, stack:, app:, instance_ids:)
      case mode
      when :parallel
        @logger.info("Creating single deployment for the #{instance_ids.size} instances...")
        create_deployment(command, stack, app, instance_ids) unless dryrun
      when :serial
        instance_ids.each.with_index do |id, i|
          @logger.info("Creating deployment for instances[#{i}] (#{id})...")
          create_deployment(command, stack, app, [id]) unless dryrun
        end
      when :one_then_all
        @logger.info("Creating deployment for the first instance (#{instance_ids[0]})...")
        create_deployment(command, stack, app, [instance_ids[0]]) unless dryrun

        rest = instance_ids[1..-1]
        if !rest.empty?
          @logger.info("Creating deployment for the other #{rest.size} instances...")
          create_deployment(command, stack, app, rest) unless dryrun
        else
          @logger.info('No other instances exist.')
        end
      else
        raise "Unknown running mode: #{mode}"
      end
    end

    private def create_deployment(command, stack, app, instance_ids)
      res = @opsworks.create_deployment(
        stack_id: stack.stack_id,
        app_id: app.app_id,
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
