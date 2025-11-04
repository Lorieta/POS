#!/usr/bin/env bash

set -o errexit

# Install dependencies
npm install

# Build the Vue app
npm run build
