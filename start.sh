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
  echo 'Adjusting Permission...'
  chown -R www-data:www-data /var/www/html ||
    {
      echo 'Permission Adjustment Failed'
      exit 1
    }
fi

#Start apache2
exec apache2-foreground
