#!/bin/bash
# Configure the environment, then hand control over to whatever command was
# requested (e.g., bash). env.sh must be sourced, not exec'ed, so the PATH
# it exports survives into the exec'd process.
source /usr/local/lib/dev-env.sh

exec "$@"
