# frozen_string_literal: true

module Opsup
  class Config
    attr_reader :stack_name
    attr_reader :aws_access_key_id
    attr_reader :aws_secret_access_key
    attr_reader :opsworks_region
    attr_reader :running_mode

    MODES = %i[parallel serial one_then_all].freeze

    def initialize(
      stack_name:,
      aws_access_key_id:,
      aws_secret_access_key:,
      opsworks_region:,
      running_mode: nil
    )
      @stack_name = stack_name
      @aws_access_key_id = aws_access_key_id
      @aws_secret_access_key = aws_secret_access_key
      @opsworks_region = opsworks_region
      @running_mode = running_mode || MODES[0]
    end

    def to_h
      {
        stack_name: stack_name,
        aws_access_key_id: aws_access_key_id,
        aws_secret_access_key: aws_secret_access_key,
        opsworks_region: opsworks_region,
        running_mode: running_mode,
      }
    end
  end
end
