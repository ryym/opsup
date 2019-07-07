# frozen_string_literal: true

module Opsup
  class Config
    attr_reader :stack_name

    def initialize(stack:)
      @stack_name = stack
    end
  end
end
