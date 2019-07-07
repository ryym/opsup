# frozen_string_literal: true

module Opsup
  class Config
    attr_reader :stack_name
    attr_reader :aws_access_key_id
    attr_reader :aws_secret_access_key
    attr_reader :opsworks_region

    def initialize(
      stack:,
      aws_access_key_id:,
      aws_secret_access_key:,
      opsworks_region:
    )
      @stack_name = stack
      @aws_access_key_id = aws_access_key_id
      @aws_secret_access_key = aws_secret_access_key
      @opsworks_region = opsworks_region
    end

    def to_h
      {
        stack_name: stack_name,
        aws_access_key_id: aws_access_key_id,
        aws_secret_access_key: aws_secret_access_key,
        opsworks_region: opsworks_region,
      }
    end
  end
end
