# Opsup

Opsup is a small command line tool to run commands for [AWS OpsWorks][aws-opsworks].

I created this as an internal tool for my work.

[aws-opsworks]: https://aws.amazon.com/jp/opsworks/

## Installation

```ruby
gem install opsup
```

## Usage

Currently Opsup can run these commands:

- `update_cookbooks`
- `setup`
- `configure`
- `deploy`

Example:

```bash
$ opsup --stack $YOUR_STACK_NAME --aws-cred $AWS_KEY,$AWS_SECRET deploy
```

Opsup waits until the command completes.

### TODO

- Add a command to build cookbooks and upload them to S3
- Write tests
- (maybe) Load options from environment varibles or a configuration file
- (maybe) Add commands to create, start, stop, and delete instances
