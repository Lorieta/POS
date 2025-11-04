#!/usr/bin/env bash

set -o errexit

bundle install

# Run database migrations
bin/rails db:migrate

# Install solid cable, cache, and queue tables (Rails 8)
bin/rails db:migrate:cable
bin/rails db:migrate:cache  
bin/rails db:migrate:queue

# Precompile assets
bin/rails assets:precompile
bin/rails assets:clean