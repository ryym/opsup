FROM ruby:2.6.3

# https://bundler.io/blog/2019/01/03/announcing-bundler-2.html
RUN gem update --system && gem install bundler:2.0.1

WORKDIR /opsup/

COPY Gemfile Gemfile.lock opsup.gemspec /opsup/
COPY bin /opsup/bin
COPY lib /opsup/lib

RUN bundle install

ENV PATH=/opsup/bin:$PATH
ENTRYPOINT ["opsup"]

