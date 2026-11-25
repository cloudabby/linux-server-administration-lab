#!/bin/bash
# create-users.sh - creates team groups and users for the lab
# Safe to run multiple times (idempotent). Must be run as root.
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run as root (use sudo)." >&2
  exit 1
fi

TEAM_GROUPS=(devs ops hr)

for g in "${TEAM_GROUPS[@]}"; do
  if getent group "$g" >/dev/null; then
    echo "Group $g already exists, skipping."
  else
    groupadd "$g"
    echo "Created group $g"
  fi
done

create_user() {
  local user=$1 group=$2
  if id "$user" &>/dev/null; then
    echo "User $user already exists, skipping."
  else
    useradd -m -s /bin/bash -g "$group" "$user"
    chage -M 90 -m 7 -W 14 "$user"
    echo "Created user $user (primary group: $group)"
  fi
}

create_user alice devs
create_user bob   ops
create_user carol hr

echo "Done. Set passwords with: sudo passwd <username>"