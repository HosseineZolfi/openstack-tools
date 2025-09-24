#!/bin/bash
# Pause all instances first, then lock them
set -Eeuo pipefail

AUTO_YES="${1:-}"

echo "Fetching the full list of instances..."
openstack server list --long || { echo "ERROR: Failed to list servers. Is your OpenStack CLI/auth configured?"; exit 2; }
echo

# Confirm
if [[ "$AUTO_YES" != "-y" && "$AUTO_YES" != "--yes" ]]; then
  read -p "Proceed to PAUSE and then LOCK all ACTIVE & unlocked instances? (yes/no): " CONFIRM
  [[ "$CONFIRM" == "yes" ]] || { echo "Aborted."; exit 0; }
fi

# Helper: get uppercased status for an ID
get_status() {
  openstack server show "$1" -f value -c status 2>/dev/null | tr '[:lower:]' '[:upper:]' || echo ""
}

# Helper: get locked flag (works whether field is 'locked' or 'OS-EXT-STS:locked')
get_locked() {
  local v
  v=$(openstack server show "$1" -f value -c locked 2>/dev/null || true)
  if [[ -z "$v" ]]; then
    # Many clouds expose it as OS-EXT-STS:locked
    v=$(openstack server show "$1" -f value -c "OS-EXT-STS:locked" 2>/dev/null || true)
  fi
  # Normalize to lowercase
  echo "$v" | tr '[:upper:]' '[:lower:]'
}

# Collect all server IDs
mapfile -t ALL_IDS < <(openstack server list -f value -c ID)

# Determine eligible instances (ACTIVE and unlocked)
ELIGIBLE_IDS=()
for ID in "${ALL_IDS[@]}"; do
  STATUS=$(get_status "$ID")
  LOCKED=$(get_locked "$ID")
  if [[ "$STATUS" == "ACTIVE" && "$LOCKED" != "true" && "$LOCKED" != "yes" ]]; then
    ELIGIBLE_IDS+=("$ID")
  fi
done

if [[ ${#ELIGIBLE_IDS[@]} -eq 0 ]]; then
  echo "No eligible instances (ACTIVE & unlocked) found."
  exit 0
fi

echo "Eligible instance IDs:"
printf '  %s\n' "${ELIGIBLE_IDS[@]}"
echo

# Final confirmation
if [[ "$AUTO_YES" != "-y" && "$AUTO_YES" != "--yes" ]]; then
  read -p "Final confirmation to PAUSE then LOCK ${#ELIGIBLE_IDS[@]} instance(s)? (yes/no): " FINAL
  [[ "$FINAL" == "yes" ]] || { echo "Aborted."; exit 0; }
fi
echo

# Step 1: Pause all eligible instances
echo "Pausing instances..."
SUCCESS=0
FAIL=0

for ID in "${ELIGIBLE_IDS[@]}"; do
  NAME=$(openstack server show "$ID" -f value -c name 2>/dev/null || echo "$ID")
  echo "==> $NAME ($ID)"

  STATUS=$(get_status "$ID")
  if [[ "$STATUS" != "PAUSED" ]]; then
    echo "  Pausing..."
    if ! openstack server pause "$ID"; then
      echo "  ERROR: pause failed. (Some clouds disallow pause; you may need 'suspend' or different RBAC.)"
      ((FAIL++)); echo; continue
    fi
  else
    echo "  Already paused."
  fi

  ((SUCCESS++))
  echo "  Done pausing."
  echo
done

echo "Summary for Pausing: ${SUCCESS} succeeded, ${FAIL} failed."
echo

# Step 2: Lock all eligible instances after pausing
echo "Locking instances..."
SUCCESS_LOCK=0
FAIL_LOCK=0

for ID in "${ELIGIBLE_IDS[@]}"; do
  NAME=$(openstack server show "$ID" -f value -c name 2>/dev/null || echo "$ID")
  echo "==> $NAME ($ID)"

  LOCKED=$(get_locked "$ID")
  if [[ "$LOCKED" == "true" || "$LOCKED" == "yes" ]]; then
    echo "  Already locked."
  else
    echo "  Locking..."
    if ! openstack server lock "$ID"; then
      echo "  ERROR: lock failed. (If you see 'Policy doesn't allow compute:lock', you need admin permission.)"
      ((FAIL_LOCK++)); echo; continue
    fi
  fi

  ((SUCCESS_LOCK++))
  echo "  Done locking."
  echo
done

echo "Summary for Locking: ${SUCCESS_LOCK} succeeded, ${FAIL_LOCK} failed."
echo "All operations completed."
