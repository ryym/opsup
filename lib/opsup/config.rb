# typed: strict
# frozen_string_literal: true

module Opsup
  class Config
    extend T::Sig

    sig { returns(String) }
    attr_reader :stack_name

    sig { returns(String) }
    attr_reader :aws_access_key_id

    sig { returns(String) }
    attr_reader :aws_secret_access_key

    sig { returns(String) }
    attr_reader :opsworks_region

    sig { returns(T.nilable(String)) }
    attr_reader :cookbook_url

    sig { returns(T.nilable(String)) }
    attr_reader :s3_bucket_name

    sig { returns(T.nilable(String)) }
    attr_reader :s3_region

    sig { returns(Symbol) }
    attr_reader :running_mode

    sig { returns(T::Boolean) }
    attr_reader :dryrun

    MODES = T.let(%i[parallel serial one_then_all].freeze, T::Array[Symbol])

    sig do
      params(
        stack_name: String,
        aws_access_key_id: String,
        aws_secret_access_key: String,
        opsworks_region: String,
        cookbook_url: T.nilable(String),
        s3_bucket_name: T.nilable(String),
        s3_region: T.nilable(String),
        running_mode: T.nilable(Symbol),
        dryrun: T::Boolean,
      ).void
    end
    def initialize(
      stack_name:,
      aws_access_key_id:,
      aws_secret_access_key:,
      opsworks_region:,
      cookbook_url:,
      s3_bucket_name: nil,
      s3_region: nil,
      running_mode: nil,
      dryrun: false
    )
      @stack_name = T.let(stack_name, String)
      @aws_access_key_id = T.let(aws_access_key_id, String)
      @aws_secret_access_key = T.let(aws_secret_access_key, String)
      @opsworks_region = T.let(opsworks_region, String)
      @cookbook_url = T.let(cookbook_url, T.nilable(String))
      @s3_bucket_name = T.let(s3_bucket_name, T.nilable(String))
      @s3_region = T.let(s3_region, T.nilable(String))
      @running_mode = T.let(running_mode || MODES.fetch(0), Symbol)
      @dryrun = T.let(dryrun, T::Boolean)
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h
      {
        stack_name: stack_name,
        aws_access_key_id: aws_access_key_id,
        aws_secret_access_key: aws_secret_access_key,
        opsworks_region: opsworks_region,
        cookbook_url: cookbook_url,
        s3_bucket_name: s3_bucket_name,
        s3_region: s3_region,
        running_mode: running_mode,
        dryrun: dryrun,
      }
    end
  end
end
