#!/bin/bash
set -e

# Optional: small log
echo "[entrypoint] Container hostname: ${HOSTNAME}"

# If AZP_AGENT_NAME is not provided, generate one using prefix + hostname
if [ -z "${AZP_AGENT_NAME}" ]; then
  if [ -n "${AZP_AGENT_NAME_PREFIX}" ]; then
    export AZP_AGENT_NAME="${AZP_AGENT_NAME_PREFIX}-${HOSTNAME}"
  else
    export AZP_AGENT_NAME="${HOSTNAME}"
  fi
fi

echo "[entrypoint] Using AZP_AGENT_NAME=${AZP_AGENT_NAME}"
echo "[entrypoint] Starting Azure DevOps agent via ./start.sh"

# Hand over to the original Microsoft start script
# (this is the one that already exists in your image/repo)
exec ./start.sh "$@"
