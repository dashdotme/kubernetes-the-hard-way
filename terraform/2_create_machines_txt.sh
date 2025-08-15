#!/usr/bin/env bash

# Creates two files by parsing terraform output -
# 1) machines.txt - the file recommended in kubernetes the hard way docs
# 2) machines_private.txt - the same file but using private ips, which are required
# to make step 11 (pod routing) work on digital ocean

# Also scp's the files onto the jumpbox, to save a step.

terraform output -json machine_ips | jq -r '
to_entries[] | select(.key != "jumpbox") |
if .key == "server" then
  "\(.value.public_ip) \(.key).kubernetes.local \(.key)"
else
  "\(.value.public_ip) \(.key).kubernetes.local \(.key) 10.200.\(.key | gsub("node-"; "") | tonumber).0/24"
end
' > machines.txt

terraform output -json machine_ips | jq -r '
to_entries[] | select(.key != "jumpbox") |
if .key == "server" then
  "\(.value.private_ip) \(.key).kubernetes.local \(.key)"
else
  "\(.value.private_ip) \(.key).kubernetes.local \(.key) 10.200.\(.key | gsub("node-"; "") | tonumber).0/24"
end
' > machines_private.txt

scp machines*.txt root@jumpbox:/root/
