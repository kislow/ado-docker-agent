#!/bin/bash

# If AZP_AGENT_NAME is not set, auto-generate one.
if [ -z "$AZP_AGENT_NAME" ]; then
  if [ -n "$AZP_AGENT_NAME_PREFIX" ]; then
    export AZP_AGENT_NAME="${AZP_AGENT_NAME_PREFIX}-${HOSTNAME}"
  else
    export AZP_AGENT_NAME="${HOSTNAME}"
  fi
fi
