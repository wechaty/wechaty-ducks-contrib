#!/usr/bin/env bash
set -e

VERSION=$(npx pkg-jq -r .version)

if npx --package @chatie/semver semver-is-prod $VERSION; then
  NPM_TAG=latest
else
  NPM_TAG=next
fi

npm run dist
npm run pack

TMPDIR="/tmp/npm-pack-testing.$$"
mkdir "$TMPDIR"
mv ./*-*.*.*.tgz "$TMPDIR"
cp tests/fixtures/smoke-testing.ts "$TMPDIR"

cd $TMPDIR
npm init -y
npm install *-*.*.*.tgz \
  @chatie/tsconfig \
  "wechaty@$NPM_TAG" \
  ducks \
  wechaty-redux \

./node_modules/.bin/tsc \
  --esModuleInterop \
  --lib esnext \
  --skipLibCheck \
  --noEmitOnError \
  --noImplicitAny \
  smoke-testing.ts

node smoke-testing.js
