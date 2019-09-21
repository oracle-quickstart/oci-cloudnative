#!/usr/bin/env sh

echo -e "\nBuilding as ${NODE_ENV}..."
if [ "$NODE_ENV" = "production" ]; then
  npm run build
  npm prune --production
  echo "done"
else
  echo "ok"
fi