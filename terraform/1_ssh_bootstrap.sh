#!/usr/bin/env bash

# Helper to allow simpler ssh connections ie. ssh server, ssh node-0, ssh node-1
# Rather than ssh root@server etc.

terraform output -json machine_ips |
  jq -r 'to_entries[] |
    "Host \(.key)
      HostName \(.value.public_ip)
      User root
      ForwardX11 yes
  "'
