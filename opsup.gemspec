# frozen_string_literal: true

require_relative 'lib/opsup/version'

Gem::Specification.new do |s|
  s.name = 'opsup'
  s.version = Opsup::VERSION
  s.authors = ['ryym']
  s.email = ['ryym.64@gmail.com']
  s.homepage = 'https://github.com/ryym/opsup'
  s.summary = 'CLI to run commands for AWS OpsWorks'
  s.license = 'MIT'
  s.required_ruby_version = '>= 2.6'
  s.files = Dir['bin/*', 'lib/**/*', 'LICENSE', 'README.md']
  s.bindir = 'bin'
  s.executables = ["opsup"]

  s.add_dependency 'aws-sdk-opsworks', '~> 1.0'

  s.add_development_dependency 'rubocop', '~> 0.71'
  s.add_development_dependency 'sorbet', '~> 0.4'
  s.add_development_dependency 'sorbet-runtime', '~> 0.4'
end
