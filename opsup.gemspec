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
  s.files = Dir['lib/**/*', 'LICENSE', 'README.md']
end
