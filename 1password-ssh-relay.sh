#!/bin/bash
set -e

export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"

if [ -S "$SSH_AUTH_SOCK" ]; then
    rm -f "$SSH_AUTH_SOCK"
fi

while true; do
  echo "Starting npiperelay bridge at $(date)" >> "$HOME/.ssh/relay.log"
  socat UNIX-LISTEN:"$SSH_AUTH_SOCK",fork EXEC:'/mnt/c/tools/npiperelay/npiperelay.exe -ei -s //./pipe/openssh-ssh-agent' \
    >> "$HOME/.ssh/relay.log" 2>&1
  echo "npiperelay bridge stopped unexpectedly, restarting in 5s..." >> "$HOME/.ssh/relay.log"
  sleep 5
done &

