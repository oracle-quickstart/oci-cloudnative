#!/usr/bin/env sh

echo "
Building as ${NODE_ENV}..."
if [ "$NODE_ENV" = "production" ]; then
  npm run build
  npm prune --production
  rm -rf src
  echo "done"
else
  echo "ok"
fi