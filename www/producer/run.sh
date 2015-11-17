#!/bin/sh

export UNICORN_PORT=8000

bundle exec unicorn \
  --include lib \
  --require pry \
  --config-file config/unicorn.rb
