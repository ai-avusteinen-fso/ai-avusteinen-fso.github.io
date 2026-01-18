#!/usr/bin/env bash

set -eEuo pipefail

case "${MODE:-}" in
  "build")
    npm run build

    if [ ! -d /output ]; then
      echo " -- Build completed, no /output volume mounted, skipping copy"
      exit 0
    fi

    rm -rf /output/*
    cp -r public/* /output/

    echo " -- Build completed, output copied to /output"
    exit 0
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
