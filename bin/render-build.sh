#!/usr/bin/env bash
set -o errexit

bundle install
npm ci
npm run build:css

bin/rails assets:precompile
bin/rails assets:clean
bin/rails db:migrate
