# frozen_string_literal: true

module Opsup
  class Config
    attr_reader :stack_name
    attr_reader :aws_access_key_id
    attr_reader :aws_secret_access_key

    def initialize(
      stack:,
      aws_access_key_id:,
      aws_secret_access_key:
    )
      @stack_name = stack
      @aws_access_key_id = aws_access_key_id
      @aws_secret_access_key = aws_secret_access_key
    end
  end
end
