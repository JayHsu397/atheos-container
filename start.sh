#! /usr/bin/env bash

set -euo pipefail

LAZY_PERMISSION="${LAZY_PERMISSION:-false}"

# Check if variables are legal
VAR_BOOL=("$LAZY_PERMISSION")

for var in "${VAR_BOOL[@]}"; do
  [[ "$var" != "true" && "$var" != "false" ]] &&
    echo "Please use 'true' or 'false', received: $var" && exit 2
done

#Adjust Permission if LAZY_PERMISSION is "true"
if [[ "${LAZY_PERMISSION}" == "true" ]]; then
  {
    echo 'Adjusting Permission (own)...'
    chown -R www-data:www-data /var/www/html
  } || {
    echo 'E: PERMISSION ADJUSTMENT FAILED (own)'
    exit 1
  }

  {
    echo 'Adjusting Permission (mod)...'
    chmod -R u+rwX,g+rwX /var/www/html
  } || {
    echo 'E: PERMISSION ADJUSTMENT FAILED (mod)'
    exit 1
  }
fi

#Start apache2
echo 'Starting Apache2...'
exec apache2-foreground
