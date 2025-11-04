#!/usr/bin/env bash

set -o errexit

bundle install

# Create database if it doesn't exist and run migrations
bin/rails db:create db:schema:load db:migrate

# Precompile assets
bin/rails assets:precompile
bin/rails assets:clean