# typed: strict
# frozen_string_literal: true

module Opsup
  class CookbookUploader
    extend T::Sig

    class S3ObjectConfig < T::Struct
      const :bucket_name, String
      const :key, String
    end

    sig do
      params(
        s3: Aws::S3::Client,
        config: Opsup::Config,
      ).returns(Opsup::CookbookUploader)
    end
    def self.create(s3:, config:)
      new(s3: s3, config: config, logger: Opsup::Logger.instance)
    end

    sig do
      params(
        s3: Aws::S3::Client,
        config: Opsup::Config,
        logger: ::Logger,
      ).void
    end
    def initialize(s3:, config:, logger:)
      @s3 = T.let(s3, Aws::S3::Client)
      @config = T.let(config, Opsup::Config)
      @logger = T.let(logger, ::Logger)
    end

    sig { params(cookbook_url: String, s3_object_config: S3ObjectConfig).void }
    def build_and_upload(cookbook_url:, s3_object_config:)
      Dir.mktmpdir do |work_dir|
        clone(work_dir, cookbook_url)
        package_path = build(work_dir)
        upload(package_path, s3_object_config)
      end
    end

    sig { params(cmd: String).void }
    private def system(cmd)
      if @config.dryrun
        @logger.info("(dryrun) #{cmd}")
      else
        super(cmd)
      end
    end

    sig { params(dir: String, url: String).void }
    private def clone(dir, url)
      system("git clone --depth=1 #{url} #{dir}")
    end

    sig { params(dir: String).returns(String) }
    private def build(dir)
      Dir.chdir(dir) do
        system('bundle')
        system('bundle exec berks package built.tar.gz')
      end
      "#{dir}/built.tar.gz"
    end

    sig { params(package_path: String, object_config: S3ObjectConfig).void }
    private def upload(package_path, object_config)
      unless @config.dryrun
        @s3.put_object(
          bucket: object_config.bucket_name,
          body: File.open(package_path),
          key: object_config.key,
        )
      end
      @logger.info("cookbook #{object_config.key} uploaded")
    end
  end
end
