#!/bin/bash
set -euo pipefail

input=$(cat)

# Extract file_path or filePath from JSON using bash regex
if [[ "$input" =~ \"file_path\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
  file_path="${BASH_REMATCH[1]}"
elif [[ "$input" =~ \"filePath\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
  file_path="${BASH_REMATCH[1]}"
else
  exit 0
fi

# Only compile .ex files (not .exs scripts/tests - they're compiled on demand)
if [[ "$file_path" == *.ex ]]; then
  if [ -f "$file_path" ]; then
    # Find mix.exs by walking up from the file
    dir=$(dirname "$file_path")
    while [[ "$dir" != "/" ]]; do
      if [[ -f "$dir/mix.exs" ]]; then
        cd "$dir"
        mix compile --warnings-as-errors || exit 2
        break
      fi
      dir=$(dirname "$dir")
    done
  fi
fi

exit 0
