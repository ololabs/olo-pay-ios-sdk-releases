#!/bin/bash
carthage update --use-xcframeworks --no-use-binaries --platform iOS
if [ $? -ne 0 ]; then
  echo "Carthage update failed, retrying..."
  carthage update --use-xcframeworks --no-use-binaries --platform iOS
fi
