# typed: true
# frozen_string_literal: true

module Opsup
  class Config
    attr_reader :stack_name
    attr_reader :aws_access_key_id
    attr_reader :aws_secret_access_key
    attr_reader :opsworks_region
    attr_reader :running_mode
    attr_reader :dryrun

    MODES = %i[parallel serial one_then_all].freeze

    def initialize(
      stack_name:,
      aws_access_key_id:,
      aws_secret_access_key:,
      opsworks_region:,
      running_mode: nil,
      dryrun: false
    )
      @stack_name = stack_name
      @aws_access_key_id = aws_access_key_id
      @aws_secret_access_key = aws_secret_access_key
      @opsworks_region = opsworks_region
      @running_mode = running_mode || MODES[0]
      @dryrun = dryrun
    end

    def to_h
      {
        stack_name: stack_name,
        aws_access_key_id: aws_access_key_id,
        aws_secret_access_key: aws_secret_access_key,
        opsworks_region: opsworks_region,
        running_mode: running_mode,
        dryrun: dryrun,
      }
    end
  end
end
