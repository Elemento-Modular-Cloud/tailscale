#!/bin/bash

# Load persistent iptables rules
declare -A forwards

while IFS='=' read -r chain forward; do
  forwards["$chain"]="$forward"
done < /iptables/forwards

if [ -d "/iptables" ]; then
  for f in /iptables/*.*; do
      bn=$(basename "$f")
      CHAIN="${bn%%.*}"
      TABLE="${bn##*.}"
      xargs -L1 iptables -t "$TABLE" < $f

      if ! iptables -C "${forwards[$CHAIN]}" -t "$TABLE" -j "$CHAIN" 2>&1 >/dev/null; then
        iptables -I "${forwards[$CHAIN]}" -t "$TABLE" -j "$CHAIN"
      fi
  done
fi

/usr/local/bin/containerboot
