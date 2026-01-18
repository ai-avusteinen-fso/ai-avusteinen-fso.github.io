#!/usr/bin/env bash

set -eEuo pipefail

case "${MODE:-}" in
  "build")
    exec npm run build
    ;;
  "dev")
    npm run build
    echo " -- Starting Gatsby in develop mode"
    exec gatsby develop --host=0.0.0.0
    ;;
  *)
    echo "Unknown MODE: '${MODE:-}'"
    exit 1
    ;;
esac
