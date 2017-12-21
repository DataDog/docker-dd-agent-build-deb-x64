#!/bin/bash -e

cd /dd-agent-omnibus

# Allow to use a different dd-agent-omnibus branch
git fetch --all
git checkout $OMNIBUS_BRANCH
git reset --hard origin/$OMNIBUS_BRANCH

# running the entrypoint from dd-agent-omnibus
cd /
bash -l /dd-agent-omnibus/omnibus_build.sh
