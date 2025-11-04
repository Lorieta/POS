#!/usr/bin/env bash

set -o errexit

bundle install
bin/rails assets:precompile
bin/rails assets:clean

# Run main database migrations
bin/rails db:migrate

# Setup solid cable, cache, and queue (Rails 8)
bin/rails db:prepare