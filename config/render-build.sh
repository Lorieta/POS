#!/usr/bin/env bash

set -o errexit

export RAILS_ENV=${RAILS_ENV:-production}
export RACK_ENV=${RACK_ENV:-production}
export NODE_ENV=${NODE_ENV:-production}

bundle install

# Run database migrations against the production database
bundle exec rails db:migrate

# Precompile assets after the database is ready
bundle exec rails assets:precompile
bundle exec rails assets:clean